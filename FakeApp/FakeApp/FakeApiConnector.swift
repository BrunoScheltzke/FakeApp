//
//  FakeApiConnector.swift
//  FakeApp
//
//  Created by Bruno Scheltzke on 10/09/18.
//  Copyright © 2018 Bruno Scheltzke. All rights reserved.
//

import Foundation
import CryptoSwift

class FakeApiConnector {
    static let shared = FakeApiConnector()
    private init() {
        apiIP = "http://localhost:3000"
        dateFor.dateFormat = "yyyy-MM-dd'T'HH:mm:ss:SSS"
    }
    
    var apiIP: String {
        didSet {
            apiIP = "http://\(apiIP)"
            print(apiIP)
        }
    }
    
    lazy private var votePath = "\(apiIP)/vote"
    lazy private var verifyNewsPath = "\(apiIP)/news/"
    lazy private var createUserPath = "\(apiIP)/createBlock"
    
    private let voteKey = "vote"
    private let newsKey = "newsURL"
    private let publicKeyKey = "userPublicKey"
    private let aesKeyKey = "aesKey"
    private let signatureKey = "signature"
    private let dateKey = "date"
    private let encryptedVoteKey = "encryptedVote"
    
    //Temporary Keychain
    private var privateKey: SecKey!
    private var publicKey: SecKey!
    private var serverAESKey: Array<UInt8>?
    
    private var publicKeyString = ""
    private var privateKeyString = ""
    
    private let session = URLSession.shared
    
    private var dateFor: DateFormatter = DateFormatter()
    
    func createUser(completion: @escaping (Bool, Error?) -> Void) {
        //generate private key and temporarely store it in this shared instance privately
        let attributes: CFDictionary =
            [kSecAttrKeyType as String: kSecAttrKeyTypeRSA,
             kSecAttrKeySizeInBits as String: 1024] as CFDictionary
        
        var error: Unmanaged<CFError>?
        guard let generatedKey = SecKeyCreateRandomKey(attributes, &error) else {
            completion(false, error!.takeRetainedValue() as Error)
            return
        }
        
        privateKey = generatedKey
        
        //get string out of private key
        var error2: Unmanaged<CFError>?
        guard let privateKeyData = SecKeyCopyExternalRepresentation(privateKey, &error2) as Data? else {
            completion(false, error2!.takeRetainedValue() as Error)
            return
        }
        
        privateKeyString = privateKeyData.base64EncodedString()
        
        //generate public key and temporarely store it in this shared instance privately
        publicKey = SecKeyCopyPublicKey(generatedKey)
        
        //prepare public key to send to server
        var error3: Unmanaged<CFError>?
        guard let dataKey = SecKeyCopyExternalRepresentation(publicKey, &error3) as Data? else {
            completion(false, error3!.takeRetainedValue() as Error)
            return
        }
        
        let keyString = dataKey.base64EncodedString()
        publicKeyString = keyString
        
        
        //prepare request
        let data = [publicKeyKey: keyString]
        guard let request = buildPostRequest(fromPath: createUserPath, with: data) else {
            completion(false, nil)
            return
        }
        //make call to server requesting creation of user with public key
        let task = session.dataTask(with: request) { [unowned self] (resultData, response, resultError) in
            //on response, get aeskey and temporarely store it in this shared instance privately
            guard let data = resultData,
                let json = try? JSONSerialization.jsonObject(with: data, options: []),
                let dict = json as? [String: Any],
                let strEncryptedAESKey = dict[self.aesKeyKey] as? String,
                let encryptedData = Data(base64Encoded: strEncryptedAESKey) else {
                    completion(false, resultError)
                    return
            }
            
            var error4: Unmanaged<CFError>?
            guard let clearText = SecKeyCreateDecryptedData(self.privateKey,
                                                            SecKeyAlgorithm.rsaEncryptionRaw,
                                                            encryptedData as CFData,
                                                            &error4) as Data? else {
                                                                let dasError =  error4!.takeRetainedValue() as Error
                                                                completion(false, dasError)
                                                                return
            }
            
            self.serverAESKey = clearText.bytes.filter { $0 != 0 }

            completion(true, nil)
        }
        
        task.resume()
    }
    
    func vote(_ vote: String, forNews news: String, completion: @escaping (Bool, Error?) -> Void) {
        //make sure user has established connection with blockchain
        guard let serverKey = serverAESKey else {
            completion(false, nil)
            return
        }
        
        //create vote data
        let jsonData: [String : Any] = [voteKey: vote,
                    newsKey: news,
                    dateKey: dateFor.string(from: Date()),
                    publicKeyKey: publicKeyString]
        
        //transform it to Data
        guard let data = jsonData.toData() else {
            completion(false, nil)
            return
        }
        
        //sign it with private key
        var error: Unmanaged<CFError>?
        guard let signature = SecKeyCreateSignature(privateKey,
                                                    SecKeyAlgorithm.rsaSignatureMessagePKCS1v15SHA256,
                                                    data as CFData,
                                                    &error) as Data? else {
                                                        completion(false, error!.takeRetainedValue() as Error)
                                                        return
        }
        
        //create json with vote data and signature
        let body = [voteKey: data.base64EncodedString(),
                    signatureKey: signature.base64EncodedString()]
    
        guard let bodyData = body.toData() else {
            completion(false, nil)
            return
        }
        
        //encrypt with aes key
        var encryptedData: String
        do {
            let iv = "4242424242424242".toArrayUInt8()
            let blockMode = CBC(iv: iv)
            let aes = try AES(key: serverKey, blockMode: blockMode)
            let ciphertext = try aes.encrypt(bodyData.bytes)
            
            encryptedData = Data(ciphertext).base64EncodedString()
        } catch {
            completion(false, nil)
            return
        }
        
        //create json with publickey and encrypted data
        let jsonEncryptedVote = [publicKeyKey: publicKeyString,
                                 encryptedVoteKey: encryptedData]
        
        guard let request = buildPostRequest(fromPath: votePath, with: jsonEncryptedVote) else {
            completion(false, nil)
            return
        }
        
        //perform the request
        let task = session.dataTask(with: request) { (data, response, error) in
            if let response = response,
                let httpResponse = response as? HTTPURLResponse,
                httpResponse.statusCode == 200 {
                completion(true, nil)
            }
            
            completion(false, error)
        }
        
        task.resume()
    }
    
    func verifyVeracity(ofNews news: String, completion: @escaping ([String: Any]?, Error?) -> Void) {
        guard let url = URL(string: verifyNewsPath + news) else {
            completion(nil, nil)
            return
        }
        
        let request = URLRequest(url: url)
        
        let task = session.dataTask(with: request) { (data, response, error) in
            guard let data = data,
                let json = try? JSONSerialization.jsonObject(with: data, options: []),
                let dict = json as? [String:AnyObject] else {
                    completion(nil, error)
                    return
            }
            
            completion(dict, error)
        }
        
        task.resume()
    }
    
    private func buildPostRequest(fromPath path: String, with data: [String: Any]) -> URLRequest? {
        guard let url = URL(string: path),
            let httpBody = try? JSONSerialization.data(withJSONObject: data, options: []) else {
                return nil
        }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = httpBody
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        return request
    }
}

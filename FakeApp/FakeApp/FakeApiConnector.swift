//
//  FakeApiConnector.swift
//  FakeApp
//
//  Created by Bruno Scheltzke on 10/09/18.
//  Copyright © 2018 Bruno Scheltzke. All rights reserved.
//

import Foundation

class FakeApiConnector {
    static let shared = FakeApiConnector()
    private init() {
        apiIP = "http://localhost:3000"
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
    private let dateKey = "date"
    private let encryptedVoteKey = "vote"
    
    //Temporary Keychain
    private var privateKey: SecKey!
    private var publicKey: SecKey!
    private var serverAESKey: SecKey?
    
    private var publicKeyString = ""
    
    private let session = URLSession.shared
    
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
        
        //generate public key and temporarely store it in this shared instance privately
        publicKey = SecKeyCopyPublicKey(generatedKey)
        
        //prepare public key to send to server
        var error2: Unmanaged<CFError>?
        guard let dataKey = SecKeyCopyExternalRepresentation(publicKey, &error2) as Data? else {
            completion(false, error2!.takeRetainedValue() as Error)
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
                let encryptedAESKey = Data(base64Encoded: strEncryptedAESKey) else {
                    completion(false, resultError)
                    return
            }
            
            guard let stringAESKey = SecKeyCreateDecryptedData(self.privateKey,
                                                               SecKeyAlgorithm.rsaEncryptionOAEPSHA256AESGCM,
                                                               encryptedAESKey as CFData,
                                                               &error) as Data? else {
                                                                completion(false, error!.takeRetainedValue() as Error)
                                                                return
            }
            
            guard let dataKey = Data(base64Encoded: stringAESKey) else {
                completion(false, nil)
                return
            }
            
            let options: [String: Any] = [kSecAttrKeyType as String: kSecAttrKeyTypeRSA,
                                          kSecAttrKeyClass as String: kSecAttrKeyClassPublic,
                                          kSecAttrKeySizeInBits as String: 1024]
            
            var error: Unmanaged<CFError>?
            guard let key = SecKeyCreateWithData(dataKey as CFData,
                                                 options as CFDictionary,
                                                 &error)
                else {
                    completion(false, error!.takeRetainedValue() as Error)
                    return
                }
            
            self.serverAESKey = key
            completion(true, nil)
        }
        
        task.resume()
    }
    
    func vote(_ vote: String, forNews news: String, completion: @escaping ([String: Any]?, Error?) -> Void) {
        //create vote data
        let jsonData: [String : Any] = [voteKey: vote,
                    newsKey: news,
                    dateKey: Date(),
                    publicKeyKey: publicKeyString]
        
        //transform it to Data
        guard let data = jsonData.toData() else {
            completion(nil, nil)
            return
        }
        
        //sign it with private key
        var error: Unmanaged<CFError>?
        guard var signature = SecKeyCreateSignature(privateKey,
                                                    SecKeyAlgorithm.rsaSignatureMessagePKCS1v15SHA256,
                                                    data as CFData,
                                                    &error) as Data? else {
                                                        completion(nil, error!.takeRetainedValue() as Error)
                                                        return
        }
        
        //concat signature with vote data
        signature.append(data)
        
        //encrypt with aes key
        guard let serverAESKey = serverAESKey else {
            completion(nil, nil)
            return
        }
        
        var error2: Unmanaged<CFError>?
        guard let encryptedData = SecKeyCreateEncryptedData(serverAESKey,
                                                            SecKeyAlgorithm.rsaEncryptionOAEPSHA256AESGCM,
                                                         signature as CFData,
                                                         &error2) as Data? else {
                                                            completion(nil, error!.takeRetainedValue() as Error)
                                                            return
        }
        
        //create json with publickey and encrypted data
        let jsonEncryptedVote = [publicKeyKey: publicKeyString,
                                 encryptedVoteKey: encryptedData.base64EncodedString()]
        
        guard let request = buildPostRequest(fromPath: votePath, with: jsonEncryptedVote) else {
            completion(nil, nil)
            return
        }
        
        //perform the request
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

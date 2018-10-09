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
    lazy private var verifyNewsPath = "\(apiIP)/newsURL/"
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
    
    private let privateKeyTag = "privateKeyTag"
    private let aesKeyTag = "aesKeyTag"
    
    private let isDebugginR2ac = false
    
    // MARK: Initial Setup
    func setup(completion: @escaping (Bool, Error?) -> Void) {
        //verify if there are keys on keychain
        if let privateKey = getExistingPrivateKey() {
            //there is keys on keychain
            if let error = setupPrivateKey(privateKey) {
                //getting external representation of key can throw errors
                completion(false, error)
                return
            } else {
                //verify if there is a server aeskey
                if let aesKey = getExistingAesKey() {
                    self.serverAESKey = aesKey
                    completion(true, nil)
                    return
                } else {
                    //there is no aeskey, request new one from server
                    requestAesKey { (aesKey, error) in
                        if let key = aesKey {
                            self.serverAESKey = key
                            self.storeAesKey(key)
                            completion(true, nil)
                            return
                        } else {
                            completion(false, error)
                            return
                        }
                    }
                }
            }
        } else {
            //there is no keys on keychain
            let result = createPrivateKey()
            guard let privateKey = result.0 else {
                completion(false, result.1)
                return
            }
            
            if let error = setupPrivateKey(privateKey) {
                //getting external representation of key can throw errors
                completion(false, error)
                return
            } else {
                //request aeskey
                requestAesKey { (aesKey, error) in
                    if let key = aesKey {
                        self.serverAESKey = key
                        self.storeAesKey(key)
                        completion(true, nil)
                        return
                    } else {
                        completion(false, error)
                        return
                    }
                }
            }
        }
    }
    
    // MARK: Request AesKey
    func getExistingAesKey() -> Array<UInt8>? {
        return isDebugginR2ac ? nil : UserDefaults.standard.array(forKey: aesKeyTag) as? Array<UInt8>
    }
    
    func storeAesKey(_ aesKey: Array<UInt8>) {
        UserDefaults.standard.set(aesKey, forKey: aesKeyTag)
    }
    
    func requestAesKey(completion: @escaping(Array<UInt8>?, Error?) -> Void) {
        //prepare request
        let data = [publicKeyKey: publicKeyString]
        guard let request = buildPostRequest(fromPath: createUserPath, with: data) else {
            completion(nil, nil)
            return
        }
        //make call to server requesting creation of user with public key
        let task = session.dataTask(with: request) { [unowned self] (resultData, response, resultError) in
            
            if let response = response,
                let httpResponse = response as? HTTPURLResponse,
                httpResponse.statusCode != 200,
                let data = resultData,
                let json = try? JSONSerialization.jsonObject(with: data, options: []),
                let dict = json as? [String: Any],
                let _ = dict["error"] as? String {
                completion(nil, NSError(domain: "", code: 500, userInfo: dict))
                return
            }
            
            //on response, get aeskey and temporarely store it in this shared instance privately
            guard let data = resultData,
                let json = try? JSONSerialization.jsonObject(with: data, options: []),
                let dict = json as? [String: Any],
                let strEncryptedAESKey = dict[self.aesKeyKey] as? String,
                let encryptedData = Data(base64Encoded: strEncryptedAESKey) else {
                    completion(nil, resultError)
                    return
            }
            
            var error4: Unmanaged<CFError>?
            guard let clearText = SecKeyCreateDecryptedData(self.privateKey,
                                                            SecKeyAlgorithm.rsaEncryptionRaw,
                                                            encryptedData as CFData,
                                                            &error4) as Data? else {
                                                                let dasError =  error4!.takeRetainedValue() as Error
                                                                completion(nil, dasError)
                                                                return
            }
            
            let aesKey = clearText.bytes.filter { $0 != 0 }
            
            completion(aesKey, nil)
        }
        
        task.resume()
    }
    
    // MARK: Retrieve private key
    func getExistingPrivateKey() -> SecKey? {
        let getExistingPrivateKeyQuery: [String: Any] = [kSecClass as String: kSecClassKey,
                                                         kSecAttrApplicationTag as String: privateKeyTag,
                                                         kSecAttrKeyType as String: kSecAttrKeyTypeRSA,
                                                         kSecReturnRef as String: true]
        
        var item: CFTypeRef?
        let status = SecItemCopyMatching(getExistingPrivateKeyQuery as CFDictionary, &item)
        if status == errSecSuccess {
            let key = item as! SecKey
            return key
        } else {
            //private key does not exit
            return nil
        }
    }
    
    func setupPrivateKey(_ key: SecKey) -> Error? {
        privateKey = key
        //get string out of private key
        var error2: Unmanaged<CFError>?
        guard let privateKeyData = SecKeyCopyExternalRepresentation(privateKey, &error2) as Data? else {
            return error2!.takeRetainedValue() as Error
        }
        
        privateKeyString = privateKeyData.base64EncodedString()
        
        //generate public key and temporarely store it in this shared instance privately
        publicKey = SecKeyCopyPublicKey(key)
        
        //prepare public key to send to server
        var error3: Unmanaged<CFError>?
        guard let dataKey = SecKeyCopyExternalRepresentation(publicKey, &error3) as Data? else {
            return error3!.takeRetainedValue() as Error
        }
        
        let keyString = dataKey.base64EncodedString()
        publicKeyString = keyString
        
        return nil
    }
    
    // MARK: Create private key
    func createPrivateKey() -> (SecKey?, Error?) {
        //generate private key and store it on keychain
        let attributes: CFDictionary =
            [kSecAttrKeyType as String: kSecAttrKeyTypeRSA,
             kSecAttrKeySizeInBits as String: 1024,
             kSecPrivateKeyAttrs as String:
                [kSecAttrIsPermanent as String: true,
                 kSecAttrApplicationTag as String: privateKeyTag]] as CFDictionary
        
        var error: Unmanaged<CFError>?
        guard let generatedKey = SecKeyCreateRandomKey(attributes, &error) else {
            return (nil, error!.takeRetainedValue() as Error)
        }
        
        return (generatedKey, nil)
    }
    
    
    // MARK: Vote
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
            guard let response = response,
                let httpResponse = response as? HTTPURLResponse else {
                    completion(false, nil)
                    return
            }
            
            if httpResponse.statusCode == 200 {
                completion(true, nil)
                return
            } else {
                if let data = data,
                    let json = try? JSONSerialization.jsonObject(with: data, options: []),
                    let dict = json as? [String: Any],
                    let errorMsg = dict["errorCode"] as? String,
                    let errorCode = Int(errorMsg) {
                    switch errorCode {
                    case 11:
                        completion(false, FakeError.erro11)
                    case 12:
                        completion(false, FakeError.erro11)
                    case 13:
                        completion(false, FakeError.erro13)
                    default:
                        completion(false, FakeError.generic)
                    }
                    return
                }
            }
            
            completion(false, error)
        }
        
        task.resume()
    }
    
    // MARK: Verify News
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

public enum FakeError: Error {
    case error10, erro11, erro12, erro13, generic
}

extension FakeError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .error10:
            return NSLocalizedString("Invalid key format", comment: "Issue with public key")
        case .erro11:
            return NSLocalizedString("User does not exist", comment: "User may not be registered")
        case .erro12:
            return NSLocalizedString("User has not established connection", comment: "AESKey not found")
        case .erro13:
            return NSLocalizedString("Error on encrypted data", comment: "Invalid signature")
        case .generic:
            return NSLocalizedString("Something wrong happened", comment: "Generic error")
        }
    }
}

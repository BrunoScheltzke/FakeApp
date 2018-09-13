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
        apiIP = "http://10.41.48.96:3000"
    }
    
    var apiIP: String {
        didSet {
            apiIP = "http://\(apiIP):3000"
            print(apiIP)
        }
    }
    
    lazy private var votePath = "\(apiIP)/vote"
    lazy private var verifyNewsPath = "\(apiIP)/news/"
    lazy private var createUserPath = "\(apiIP)/createUser"
    
    private let voteKey = "vote"
    private let newsKey = "news"
    private let userKey = "user"
    private let publicKeyKey = "publicKey"
    
    //Temporary Keychain
    private var privateKey: SecKey!
    private var publicKey: SecKey!
    private var serverAESKey: SecKey?
    
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
        
        print(publicKey)
        print(publicKey.hashValue)
        
        //prepare public key to send to server
        var error2: Unmanaged<CFError>?
        guard let dataKey = SecKeyCopyExternalRepresentation(publicKey, &error) as Data? else {
            completion(false, error2!.takeRetainedValue() as Error)
            return
        }
        
        //prepare request
        guard let data = try! JSONSerialization.jsonObject(with: dataKey, options: []) as? [String : Any] else {
            completion(false, nil)
            return
        }
        guard let request = buildPostRequest(fromPath: createUserPath, with: data) else {
            completion(false, nil)
            return
        }
        
        //make call to server requesting creation of user with public key
        let task = session.dataTask(with: request) { [unowned self] (resultData, response, resultError) in
            //on response, get aeskey and temporarely store it in this shared instance privately
            guard let data = resultData else {
                completion(false, resultError)
                return
            }
            
            let options: [String: Any] = [kSecAttrKeyType as String: kSecAttrKeyTypeRSA,
                                          kSecAttrKeyClass as String: kSecAttrKeyClassPublic,
                                          kSecAttrKeySizeInBits as String: 1024]
            var error: Unmanaged<CFError>?
            guard let key = SecKeyCreateWithData(data as CFData,
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
    
    func vote(_ vote: String, forNews news: String, completion: @escaping ([String: Any]?, Error?) -> Void) {
        let data = [voteKey: vote,
                    newsKey: news,
                    userKey: "bruno"]
        
        guard let url = URL(string: votePath),
            let httpBody = try? JSONSerialization.data(withJSONObject: data, options: []) else {
                completion(nil, nil)
                return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = httpBody
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
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
}

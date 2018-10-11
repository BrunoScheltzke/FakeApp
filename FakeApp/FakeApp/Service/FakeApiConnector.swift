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
    private let encryptionManager: EncryptionManager
    private let previewManager: PreviewManager
    private init() {
        encryptionManager = EncryptionManager()
        previewManager = PreviewManager()
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
    private let reliabilityIndexKey = "reliabilityIndexKey"
    
    private var serverAESKey: Array<UInt8>?
    
    private let session = URLSession.shared
    
    private var dateFor: DateFormatter = DateFormatter()
    
    private let aesKeyTag = "aesKeyTag"
    
    private let isDebugginR2ac = true
    
    func verifyCredentials(completion: @escaping(Bool, Error?) -> Void) {
        if let key = getExistingAesKey() {
            serverAESKey = key
            completion(true, nil)
        } else {
            //get public key
            let keyRequestResult = encryptionManager.getPublicKey()
            guard let publicKey = keyRequestResult.0 else {
                completion(false, keyRequestResult.1)
                return
            }
            requestAesKey(withPublicKey: publicKey) { (aesKey, error) in
                if let key = aesKey {
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
    
    // MARK: Vote
    func vote(_ vote: Bool, forNews news: String, completion: @escaping (Bool, Error?) -> Void) {
        //make sure user has established connection with blockchain
        guard let serverKey = serverAESKey else {
            completion(false, nil)
            return
        }
        
        //encode url
        guard let news = news.base64encoded() else {
            completion(false, nil)
            return
        }
        
        //get public key
        let publicKeyResult = encryptionManager.getPublicKey()
        guard let publicKeyString = publicKeyResult.key else {
            completion(false, publicKeyResult.error)
            return
        }
        
        //create vote json
        let jsonData: [String : Any] = [voteKey: vote,
                                        newsKey: news,
                                        dateKey: dateFor.string(from: Date()),
                                        publicKeyKey: publicKeyString]
        
        //transform it to Data
        guard let data = jsonData.toData() else {
            completion(false, nil)
            return
        }
        
        //sign with private key
        let signatureResult = encryptionManager.sign(data)
        guard let signature = signatureResult.signature else {
            completion(false, signatureResult.error)
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
        guard let encryptedData = encryptionManager.encrypt(bodyData, withKey: serverKey) else {
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
    func verifyVeracity(ofNews news: String, completion: @escaping (News?, Error?) -> Void) {
        guard let news = news.base64encoded(),
            let url = URL(string: verifyNewsPath + news) else {
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
            
            let indexNum = dict[self.reliabilityIndexKey] as? Int ?? ReliabilityIndex.neutral.rawValue
            let index = ReliabilityIndex(rawValue: indexNum)!
            let decodedNews = news.base64decoded()!
            
            self.previewManager.getPreview(of: decodedNews, completion: { (result, error) in
                guard let result = result else {
                    let resultNews = News.init(portal: nil, url: decodedNews, title: nil, reliabilityIndex: index)
                    completion(resultNews, error)
                    return
                }
                
                let resultNews = News.init(portal: Portal(name: result.portal), url: decodedNews, title: result.title, reliabilityIndex: index)
                completion(resultNews, error)
            })
        }
        
        task.resume()
    }
    
    // MARK: Request AesKey
    func getExistingAesKey() -> Array<UInt8>? {
        return isDebugginR2ac ? nil : UserDefaults.standard.array(forKey: aesKeyTag) as? Array<UInt8>
    }
    
    func storeAesKey(_ aesKey: Array<UInt8>) {
        self.serverAESKey = aesKey
        UserDefaults.standard.set(aesKey, forKey: aesKeyTag)
    }
    
    func requestAesKey(withPublicKey publicKeyString: String, completion: @escaping(Array<UInt8>?, Error?) -> Void) {
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

            let decryptionResult = self.encryptionManager.decrypt(encryptedData)
            if let aesKey = decryptionResult.value {
                completion(aesKey, nil)
            } else {
                completion(nil, decryptionResult.error)
            }
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

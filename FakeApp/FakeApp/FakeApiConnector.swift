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
    
    private let voteKey = "vote"
    private let newsKey = "news"
    private let userKey = "user"
    
    private let session = URLSession.shared
    
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

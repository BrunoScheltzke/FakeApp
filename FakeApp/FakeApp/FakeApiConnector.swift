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
    private init() {}
    
    var apiIP = ""
    lazy private var votePath = "\(apiIP)/vote"
    lazy private var verifyNewsPath = "\(apiIP)/news"
    
    func vote(_ vote: String, forNews news: String, completion: @escaping () -> Void) {
        
    }
    
    func verifyReputation(ofNews news: String, completion: @escaping () -> Void) {
        
    }
}

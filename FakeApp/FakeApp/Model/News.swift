//
//  News.swift
//  FakeApp
//
//  Created by Bruno Scheltzke on 09/10/18.
//  Copyright © 2018 Bruno Scheltzke. All rights reserved.
//

import Foundation

struct News {
    
}

enum ReliabilityIndex: Int {
    case fake = 0
    case fact = 1
    
    var asString: String {
        switch self {
        case .fake: return "Fake"
        case .fact: return "Fato"
        }
    }
    
    var description: String {
        switch self {
        case .fake: return "Baseado nos usuários, concluímos que essa notícia é falsa"
        case .fact: return "Baseado nos usuários, concluímos que essa notícia é falsa"
        }
    }
}

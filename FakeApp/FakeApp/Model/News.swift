//
//  News.swift
//  FakeApp
//
//  Created by Bruno Scheltzke on 09/10/18.
//  Copyright © 2018 Bruno Scheltzke. All rights reserved.
//

import UIKit

struct News {
    let portal: Portal?
    let url: String
    let title: String?
    let reliabilityIndex: ReliabilityIndex
}

enum ReliabilityIndex: Int {
    case fake = 0
    case fact = 1
    case neutral = 2
    
    var asString: String {
        switch self {
        case .fake: return "Fake"
        case .fact: return "Fato"
        case .neutral: return "Neutro"
        }
    }
    
    var description: String {
        switch self {
        case .fake: return "Baseado na opinião dos usuários, concluímos que essa notícia é falsa."
        case .fact: return "Baseado na opinião dos usuários, concluímos que essa notícia é verdadeira."
        case .neutral: return "Não temos votos suficientes para determinar a veracidade dessa notícia. Vote e ajude!"
        }
    }
    
    var color: UIColor {
        switch self {
        case .fake: return #colorLiteral(red: 0.6784536895, green: 0.04439244277, blue: 0, alpha: 1)
        case .fact: return #colorLiteral(red: 0.001842024725, green: 0.6487192119, blue: 0.002858069079, alpha: 1)
        case .neutral: return #colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1)
        }
    }
}

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
    let voters: [UserVote]
}

enum ReliabilityIndex: Int {
    case fake = 0
    case fact = 1
    case neutral = 2
    case fakeIsh = 3
    case trueIsh = 4
    
    var asString: String {
        switch self {
        case .fake: return "Fake"
        case .fact: return "Fato"
        case .neutral: return "Neutro"
        case .fakeIsh: return "Pode ser Fake"
        case .trueIsh: return "Pode ser Fato"
        }
    }
    
    var description: String {
        switch self {
        case .fake: return "Baseado na opinião dos usuários, concluímos que essa notícia é falsa."
        case .fact: return "Baseado na opinião dos usuários, concluímos que essa notícia é verdadeira."
        case .neutral: return "Não temos votos suficientes para determinar a veracidade dessa notícia. Vote e ajude!"
        case .fakeIsh: return "A maioria das pessoas votou Fake, mas a reputação delas não é tão alta, então não podemos afirmar."
        case .trueIsh: return "A maioria das pessoas votou Fato, mas a reputação delas não é tão alta, então não podemos afirmar."
        }
    }
    
    var color: UIColor {
        switch self {
        case .fake: return #colorLiteral(red: 0.6784536895, green: 0.04439244277, blue: 0, alpha: 1)
        case .fact: return #colorLiteral(red: 0.001842024725, green: 0.6487192119, blue: 0.002858069079, alpha: 1)
        case .neutral: return #colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1)
        case .fakeIsh: return #colorLiteral(red: 1, green: 0.5034922401, blue: 0.2738988807, alpha: 1)
        case .trueIsh: return #colorLiteral(red: 0.003147053285, green: 0.9782020597, blue: 1, alpha: 1)
        }
    }
}

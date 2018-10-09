//
//  DictionaryExtension.swift
//  FakeApp
//
//  Created by Bruno Scheltzke on 14/09/18.
//  Copyright © 2018 Bruno Scheltzke. All rights reserved.
//

import Foundation

extension Dictionary {
    func toString() -> String? {
        return toData()?.base64EncodedString()
    }
    
    func toData() -> Data? {
        return try? JSONSerialization.data(withJSONObject: self, options: [])
    }
}

//
//  StringExtension.swift
//  FakeApp
//
//  Created by Bruno Scheltzke on 14/09/18.
//  Copyright © 2018 Bruno Scheltzke. All rights reserved.
//

import Foundation

extension String {
    func toArrayUInt8() -> Array<UInt8> {
        return Array(self.utf8)
    }
    
    func encodeUrl() -> String? {
        return self.addingPercentEncoding( withAllowedCharacters: NSCharacterSet.urlHostAllowed)
    }
    
    func decodeUrl() -> String? {
        return self.removingPercentEncoding
    }
    
    func base64encoded() -> String? {
        return self.data(using: .utf8)?.base64EncodedString()
    }
    
    func base64decoded() -> String? {
        if let data = Data(base64Encoded: self) {
            return String(data: data, encoding: .utf8)
        }
        return nil
    }
}

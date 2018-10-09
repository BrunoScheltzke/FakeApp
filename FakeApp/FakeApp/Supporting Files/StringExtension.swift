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
}

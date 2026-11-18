//
//  Screen+Value.swift
//  EnactWarp
//
//  Created by JSilver on 10/31/26.
//

import Digit
import Foundation
import Warp

extension Screen {
    // The size an `Enact.Screen` says the screen is.
    package init(_ value: Warp.Value) throws {
        guard case let .struct(held) = value,
            case let .double(width) = held["width"],
            case let .double(height) = held["height"]
        else {
            throw RunRefused("\(value) is not an \(EnactVocabulary.screenType)")
        }
        
        try self.init(width: width, height: height)
    }
}

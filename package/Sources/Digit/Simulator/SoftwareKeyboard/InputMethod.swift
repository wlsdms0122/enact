//
//  InputMethod.swift
//  Digit
//
//  Created by JSilver on 11/10/26.
//

import Foundation

// Composes characters no key types from several keys of the software keyboard. Which
// layer of which keyboard has those keys is the keyboard's to find.
protocol InputMethod {
    // The labels of the keys that compose the character, nil for one it does not compose.
    func spelling(of character: Character) -> [Character]?
    // Whether the character typed alone is composed into the one before it.
    func joins(_ character: Character, after previous: Character) -> Bool
}

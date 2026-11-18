//
//  Spelling.swift
//  Digit
//
//  Created by JSilver on 11/10/26.
//

import Foundation

// What types one character of a text: the software key labeled with it, the keys an
// input method composes it from, or for a return or a tab, the hardware key.
enum Spelling {
    case keys([SoftwareKey], of: Character, composed: Bool)
    case press(UInt32)
    
    // MARK: - Property
    private static let pressed: [Character: UInt32] = [
        "\n": KeyboardLayout.returnKey,
        "\t": KeyboardLayout.tab
    ]
    
    // MARK: - Initializer
    init(_ character: Character, after previous: Character?, inputMethod: any InputMethod) throws {
        if let code = Self.pressed[character] {
            self = .press(code)
            
            return
        }
        
        if character == " " {
            self = .keys([.space], of: character, composed: false)
            
            return
        }
        
        guard let spelling = inputMethod.spelling(of: character) else {
            self = .keys([.character(character)], of: character, composed: false)
            
            return
        }
        
        if let previous, inputMethod.joins(character, after: previous) {
            throw DigitError.joinedJamo(character, after: previous)
        }
        
        self = .keys(spelling.map(SoftwareKey.character), of: character, composed: true)
    }
    
    // MARK: - Public
    // MARK: - Private
}

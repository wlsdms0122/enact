//
//  SoftwareKey.swift
//  Digit
//
//  Created by JSilver on 11/10/26.
//

import Foundation

// A key of the software keyboard by what it does. Control keys are told by their
// identifier, as their labels follow the layout's language; Next keyboard by its label,
// which is the same in every layout. A character key has no identifier and its label is
// the character, or for a few, the name iOS reads the character by.
enum SoftwareKey: Hashable {
    case character(Character)
    case shift
    case more
    case space
    case nextKeyboard
    
    // MARK: - Property
    static let nextKeyboardLabel = "Next keyboard"
    
    private static let named: [String: Character] = [
        "ampersand": "&",
        "앤드 기호": "&"
    ]
    
    // MARK: - Initializer
    // Nil for a key that is neither a character nor a control typing uses.
    init?(_ key: Element) {
        switch (key.id, key.label) {
        case ("shift", _):
            self = .shift
        
        case ("more", _):
            self = .more
        
        case ("space", _):
            self = .space
        
        case (nil, Self.nextKeyboardLabel):
            self = .nextKeyboard
        
        case let (nil, label?):
            guard let character = Self.named[label] ?? (label.count == 1 ? label.first : nil) else {
                return nil
            }
            
            self = .character(character)
        
        default:
            return nil
        }
    }
    
    // MARK: - Public
    // MARK: - Private
}

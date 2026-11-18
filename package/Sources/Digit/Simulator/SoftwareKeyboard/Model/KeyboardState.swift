//
//  KeyboardState.swift
//  Digit
//
//  Created by JSilver on 11/10/26.
//

import Foundation

// A layer of a software keyboard as typing tells it apart: the keys it shows, and the
// keyboard Next keyboard switches to from it, which tells two keyboards' layers apart
// where their keys are the same.
struct KeyboardState: Hashable {
    // MARK: - Property
    let keys: Set<SoftwareKey>
    let nextKeyboard: String?
    
    // MARK: - Initializer
    // MARK: - Public
    // MARK: - Private
}

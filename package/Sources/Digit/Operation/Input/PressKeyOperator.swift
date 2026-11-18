//
//  PressKeyOperator.swift
//  Digit
//
//  Created by JSilver on 8/16/26.
//

import Foundation

public struct PressKeyOperator: Operator {
    // MARK: - Property
    public static let operation = Operation.pressKey
    
    public let press: KeyPress
    public let modifiers: [Modifier]
    
    // MARK: - Initializer
    public init(press: KeyPress, modifiers: [Modifier] = []) {
        self.press = press
        self.modifiers = modifiers
    }
    
    // MARK: - Public
    // MARK: - Private
}

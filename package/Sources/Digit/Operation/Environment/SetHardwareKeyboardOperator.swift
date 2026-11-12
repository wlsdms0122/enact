//
//  SetHardwareKeyboardOperator.swift
//  Digit
//
//  Created by JSilver on 11/9/26.
//

import Foundation

public struct SetHardwareKeyboardOperator: Operator {
    // MARK: - Property
    public static let operation = Operation.setHardwareKeyboard
    
    public let keyboard: HardwareKeyboard
    
    // MARK: - Initializer
    public init(_ keyboard: HardwareKeyboard) { self.keyboard = keyboard }
    
    // MARK: - Public
    // MARK: - Private
}

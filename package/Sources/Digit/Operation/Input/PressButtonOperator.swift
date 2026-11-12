//
//  PressButtonOperator.swift
//  Digit
//
//  Created by JSilver on 8/16/26.
//

import Foundation

public struct PressButtonOperator: Operator {
    // MARK: - Property
    public static let operation = Operation.pressButton
    
    public let button: Button
    
    // MARK: - Initializer
    public init(_ button: Button) { self.button = button }
    
    // MARK: - Public
    // MARK: - Private
}

//
//  SetAppearanceOperator.swift
//  Digit
//
//  Created by JSilver on 8/16/26.
//

import Foundation

public struct SetAppearanceOperator: Operator {
    // MARK: - Property
    public static let operation = Operation.setAppearance
    
    public let appearance: Appearance
    
    // MARK: - Initializer
    public init(_ appearance: Appearance) { self.appearance = appearance }
    
    // MARK: - Public
    // MARK: - Private
}

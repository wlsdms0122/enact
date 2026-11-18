//
//  SetAppAccessibilityOperator.swift
//  Digit
//
//  Created by JSilver on 11/11/26.
//

import Foundation

public struct SetAppAccessibilityOperator: Operator {
    // MARK: - Property
    public static let operation = Operation.setAppAccessibility
    
    public let accessibility: AppAccessibility
    
    // MARK: - Initializer
    public init(_ accessibility: AppAccessibility) { self.accessibility = accessibility }
    
    // MARK: - Public
    // MARK: - Private
}

//
//  AppAccessibilityOperator.swift
//  Digit
//
//  Created by JSilver on 11/11/26.
//

import Foundation

public struct AppAccessibilityOperator: Operator {
    public typealias Result = AppAccessibility
    
    // MARK: - Property
    public static let operation = Operation.appAccessibility
    
    // MARK: - Initializer
    public init() {}
    
    // MARK: - Public
    // MARK: - Private
}

//
//  UninstallAppOperator.swift
//  Digit
//
//  Created by JSilver on 8/16/26.
//

import Foundation

public struct UninstallAppOperator: Operator {
    // MARK: - Property
    public static let operation = Operation.uninstallApp
    
    public let bundleID: String
    
    // MARK: - Initializer
    public init(bundleID: String) { self.bundleID = bundleID }
    
    // MARK: - Public
    // MARK: - Private
}

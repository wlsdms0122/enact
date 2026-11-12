//
//  InstallAppOperator.swift
//  Digit
//
//  Created by JSilver on 8/16/26.
//

import Foundation

public struct InstallAppOperator: Operator {
    // MARK: - Property
    public static let operation = Operation.installApp
    
    public let path: String
    
    // MARK: - Initializer
    public init(path: String) { self.path = path }
    
    // MARK: - Public
    // MARK: - Private
}

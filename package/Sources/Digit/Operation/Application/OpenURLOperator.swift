//
//  OpenURLOperator.swift
//  Digit
//
//  Created by JSilver on 8/16/26.
//

import Foundation

public struct OpenURLOperator: Operator {
    // MARK: - Property
    public static let operation = Operation.openURL
    
    public let url: URL
    
    // MARK: - Initializer
    public init(_ url: URL) { self.url = url }
    
    // MARK: - Public
    // MARK: - Private
}

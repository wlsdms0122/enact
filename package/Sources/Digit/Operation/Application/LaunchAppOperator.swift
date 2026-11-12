//
//  LaunchAppOperator.swift
//  Digit
//
//  Created by JSilver on 8/16/26.
//

import Foundation

public struct LaunchAppOperator: Operator {
    public typealias Result = Int32
    
    // MARK: - Property
    public static let operation = Operation.launchApp
    
    public let bundleID: String
    public let arguments: [String]
    public let environment: [String: String]
    public let locale: String?
    public let language: String?
    
    // MARK: - Initializer
    public init(
        bundleID: String,
        arguments: [String] = [],
        environment: [String: String] = [:],
        locale: String? = nil,
        language: String? = nil
    ) {
        self.bundleID = bundleID
        self.arguments = arguments
        self.environment = environment
        self.locale = locale
        self.language = language
    }
    
    // MARK: - Public
    // MARK: - Private
}

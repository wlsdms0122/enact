//
//  AppGroupsOperator.swift
//  Digit
//
//  Created by JSilver on 8/16/26.
//

import Foundation

public struct AppGroupsOperator: Operator {
    public typealias Result = [String: String]
    
    // MARK: - Property
    public static let operation = Operation.appGroups
    
    public let bundleID: String
    
    // MARK: - Initializer
    public init(bundleID: String) { self.bundleID = bundleID }
    
    // MARK: - Public
    // MARK: - Private
}

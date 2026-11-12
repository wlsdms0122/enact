//
//  DescribeScreenOperator.swift
//  Digit
//
//  Created by JSilver on 8/16/26.
//

import Foundation

public struct DescribeScreenOperator: Operator {
    public typealias Result = Screen
    
    // MARK: - Property
    public static let operation = Operation.describeScreen
    
    // MARK: - Initializer
    public init() {}
    
    // MARK: - Public
    // MARK: - Private
}

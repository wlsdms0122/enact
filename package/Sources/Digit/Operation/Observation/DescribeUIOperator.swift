//
//  DescribeUIOperator.swift
//  Digit
//
//  Created by JSilver on 8/16/26.
//

import Foundation

public struct DescribeUIOperator: Operator {
    public typealias Result = [Element]
    
    // MARK: - Property
    public static let operation = Operation.describeUI
    
    public let point: Point?
    
    // MARK: - Initializer
    public init(at point: Point? = nil) { self.point = point }
    
    // MARK: - Public
    // MARK: - Private
}

//
//  SetContentSizeOperator.swift
//  Digit
//
//  Created by JSilver on 8/16/26.
//

import Foundation

public struct SetContentSizeOperator: Operator {
    // MARK: - Property
    public static let operation = Operation.setContentSize
    
    public let size: ContentSize
    
    // MARK: - Initializer
    public init(_ size: ContentSize) { self.size = size }
    
    // MARK: - Public
    // MARK: - Private
}

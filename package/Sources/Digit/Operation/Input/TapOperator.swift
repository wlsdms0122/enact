//
//  TapOperator.swift
//  Digit
//
//  Created by JSilver on 8/16/26.
//

import Foundation

public struct TapOperator: Operator {
    // MARK: - Property
    public static let operation = Operation.tap
    
    public let point: Point
    
    // MARK: - Initializer
    public init(at point: Point) { self.point = point }
    
    // MARK: - Public
    // MARK: - Private
}

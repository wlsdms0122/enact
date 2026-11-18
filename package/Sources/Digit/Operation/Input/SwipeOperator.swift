//
//  SwipeOperator.swift
//  Digit
//
//  Created by JSilver on 8/16/26.
//

import Foundation

public struct SwipeOperator: Operator {
    // MARK: - Property
    public static let operation = Operation.swipe
    
    public let stroke: Stroke
    
    // MARK: - Initializer
    public init(_ stroke: Stroke) { self.stroke = stroke }
    
    // MARK: - Public
    // MARK: - Private
}

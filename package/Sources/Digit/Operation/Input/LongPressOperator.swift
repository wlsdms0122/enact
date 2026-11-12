//
//  LongPressOperator.swift
//  Digit
//
//  Created by JSilver on 8/16/26.
//

import Foundation

public struct LongPressOperator: Operator {
    // MARK: - Property
    public static let operation = Operation.longPress
    
    public let point: Point
    public let duration: TimeInterval
    
    // MARK: - Initializer
    public init(at point: Point, duration: TimeInterval) throws {
        guard duration > 0 else {
            throw DigitError.notPositive(field: "duration", value: duration)
        }
        
        self.point = point
        self.duration = duration
    }
    
    // MARK: - Public
    // MARK: - Private
}

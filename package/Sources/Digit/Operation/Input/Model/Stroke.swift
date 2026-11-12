//
//  Stroke.swift
//  Digit
//
//  Created by JSilver on 8/16/26.
//

import Foundation

public struct Stroke: Sendable {
    // MARK: - Property
    public let start: Point
    public let end: Point
    public let duration: TimeInterval
    
    // MARK: - Initializer
    public init(start: Point, end: Point, duration: TimeInterval) throws {
        guard duration > 0 else {
            throw DigitError.notPositive(field: "duration", value: duration)
        }
        
        guard start.x != end.x || start.y != end.y else {
            throw DigitError.nothingToDo(field: "distance between the ends")
        }
        
        self.start = start
        self.end = end
        self.duration = duration
    }
    
    // MARK: - Public
    // MARK: - Private
}

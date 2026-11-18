//
//  MoveSliderOperator.swift
//  Digit
//
//  Created by JSilver on 8/16/26.
//

import Foundation

public struct MoveSliderOperator: Operator {
    // MARK: - Property
    public static let operation = Operation.moveSlider
    public static let knobRadius: Double = 15
    
    public let frame: Element.Frame
    public let from: Double
    public let to: Double
    public let duration: TimeInterval
    
    // MARK: - Initializer
    public init(frame: Element.Frame, from: Double, to: Double, duration: TimeInterval) throws {
        guard duration > 0 else {
            throw DigitError.notPositive(field: "duration", value: duration)
        }
        
        guard (0.0...1.0).contains(from) else {
            throw DigitError.outOfInterval(field: "from", value: from, allowed: 0...1)
        }
        
        guard (0.0...1.0).contains(to) else {
            throw DigitError.outOfInterval(field: "to", value: to, allowed: 0...1)
        }
        
        guard frame.width > Self.knobRadius * 2 else {
            throw DigitError.notPositive(
                field: "track the knob can move along",
                value: frame.width - Self.knobRadius * 2
            )
        }
        
        self.frame = frame
        self.from = from
        self.to = to
        self.duration = duration
    }
    
    // MARK: - Public
    func travel() throws -> Stroke? {
        let start = knobX(at: from)
        let end = knobX(at: to)
        
        guard start != end else { return nil }
        
        let y = frame.y + frame.height / 2
        
        return try Stroke(
            start: Point(x: start, y: y),
            end: Point(x: end, y: y),
            duration: duration
        )
    }
    
    // MARK: - Private
    private func knobX(at position: Double) -> Double {
        let radius = Self.knobRadius
        
        return frame.x + radius + (frame.width - radius * 2) * position
    }
}

//
//  SimulatorHIDEventTests.swift
//  DigitTests
//
//  Created by JSilver on 11/13/26.
//

import Foundation
import FBSimulatorControl
import Testing
@testable import Digit

@Suite("A drag traces its stroke and comes to rest before it lets go")
struct SimulatorHIDEventTests {
    // MARK: - Property
    // MARK: - Initializer
    // MARK: - Test
    @Test("a drag moves along its stroke over its duration, holds at its end a hair across it, and lifts there")
    func aDragLiftsAtRest() throws {
        // Given
        let stroke = try Stroke(start: Point(x: 100, y: 400), end: Point(x: 100, y: 100), duration: 0.3)
        
        // When
        let sut = SimulatorHIDEvent.drag(stroke, delta: 10, hold: 0.1)
        
        // Then
        guard case let .composite(events) = sut else {
            Issue.record("\(sut) is not a composite")
            
            return
        }
        
        let touches = events.compactMap(touch)
        let delays = events.compactMap(delay)
        let held = touches.dropFirst(31).dropLast()
        
        #expect(touches.first == Touch(down: true, x: 100, y: 400))
        #expect(touches.dropFirst().prefix(30).last == Touch(down: true, x: 100, y: 100))
        #expect(held.count == 6)
        #expect(held.allSatisfy { touch in touch.y == 100 && [100, 100.5].contains(touch.x) })
        #expect(Set(held.map(\.x)).count == 2)
        #expect(touches.last == Touch(down: false, x: 100, y: 100))
        #expect(abs(delays.reduce(0, +) - 0.4) < 0.000_001)
    }
    
    // MARK: - Private
    private struct Touch: Equatable {
        // MARK: - Property
        let down: Bool
        let x: Double
        let y: Double
        
        // MARK: - Initializer
        // MARK: - Public
        // MARK: - Private
    }
    
    private func touch(_ event: SimulatorHIDEvent) -> Touch? {
        guard case let .touch(direction, x, y, _) = event else { return nil }
        
        return Touch(down: direction == .down, x: x, y: y)
    }
    
    private func delay(_ event: SimulatorHIDEvent) -> TimeInterval? {
        guard case let .delay(interval) = event else { return nil }
        
        return interval
    }
}

//
//  StrokeTests.swift
//  DigitTests
//
//  Created by JSilver on 8/16/26.
//

import Testing
@testable import Digit

@Suite("A stroke takes time and goes somewhere")
struct StrokeTests {
    // MARK: - Property
    // MARK: - Initializer
    // MARK: - Test
    @Test("a stroke with no duration is refused")
    func aStrokeNeedsTime() {
        // Given
        let from = Point(x: 0, y: 0)
        let to = Point(x: 10, y: 10)
        
        // When / Then
        #expect(throws: DigitError.self) { try Stroke(start: from, end: to, duration: 0) }
        #expect(throws: Never.self) { try Stroke(start: from, end: to, duration: 0.3) }
    }
    
    @Test("a stroke that ends where it starts is refused")
    func aStrokeNeedsSomewhereToGo() {
        // Given
        let spot = Point(x: 12, y: 34)
        
        // When / Then
        #expect(throws: DigitError.self) { try Stroke(start: spot, end: spot, duration: 0.3) }
        #expect(throws: Never.self) {
            try Stroke(start: spot, end: Point(x: spot.x, y: spot.y + 1), duration: 0.3)
        }
    }
}

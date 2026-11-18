//
//  LongPressOperatorTests.swift
//  DigitTests
//
//  Created by JSilver on 8/16/26.
//

import Testing
@testable import Digit

@Suite("A long press takes time")
struct LongPressOperatorTests {
    // MARK: - Property
    // MARK: - Initializer
    // MARK: - Test
    @Test("a press held for no time is refused")
    func aPressNeedsTime() {
        // When / Then
        #expect(throws: DigitError.self) {
            try LongPressOperator(at: Point(x: 0, y: 0), duration: -1)
        }
    }
}

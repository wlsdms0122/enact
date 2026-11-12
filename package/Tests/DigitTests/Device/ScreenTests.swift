//
//  ScreenTests.swift
//  DigitTests
//
//  Created by JSilver on 8/16/26.
//

import Testing
@testable import Digit

@Suite("A screen has room in it")
struct ScreenTests {
    // MARK: - Property
    // MARK: - Initializer
    // MARK: - Test
    @Test("a side of zero is refused", arguments: [(0.0, 800.0), (400.0, 0.0)])
    func anEmptySideIsRefused(width: Double, height: Double) {
        // When / Then
        #expect(throws: DigitError.self) { try Screen(width: width, height: height) }
    }
    
    @Test("a screen with both sides is accepted")
    func aScreenWithRoomIsAccepted() {
        // When / Then
        #expect(throws: Never.self) { try Screen(width: 400, height: 800) }
    }
}

//
//  SetStatusBarOperatorTests.swift
//  DigitTests
//
//  Created by JSilver on 8/16/26.
//

import Testing
@testable import Digit

@Suite("A status bar override keeps counts in range")
struct SetStatusBarOperatorTests {
    // MARK: - Property
    // MARK: - Initializer
    // MARK: - Test
    @Test("a count outside its range is refused")
    func statusBarRejectsCountsOutsideTheirRange() {
        // When / Then
        #expect(throws: DigitError.self) { try SetStatusBarOperator(wifiBars: 9) }
        #expect(throws: DigitError.self) { try SetStatusBarOperator(cellularBars: 5) }
        #expect(throws: DigitError.self) { try SetStatusBarOperator(batteryLevel: 500) }
    }
    
    @Test("counts at the top of their range are accepted")
    func countsInRangeAreAccepted() {
        // When / Then
        #expect(throws: Never.self) {
            try SetStatusBarOperator(time: "9:41", wifiBars: 3, batteryLevel: 100)
        }
    }
}

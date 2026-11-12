//
//  StreamVideoOperatorTests.swift
//  DigitTests
//
//  Created by JSilver on 11/10/26.
//

import Testing
@testable import Digit

@Suite("A stream sends frames as the screen changes or at a rate above zero")
struct StreamVideoOperatorTests {
    // MARK: - Property
    // MARK: - Initializer
    // MARK: - Test
    @Test("a rate of zero or less is refused", arguments: [0, -1])
    func aRateHasToBePositive(framesPerSecond: Int) {
        // When / Then
        #expect(throws: DigitError.self) {
            try StreamVideoOperator(framesPerSecond: framesPerSecond) { _ in }
        }
    }
    
    @Test("no rate, or a positive one, is taken", arguments: [nil, 1, 30] as [Int?])
    func noRateOrAPositiveOneIsTaken(framesPerSecond: Int?) throws {
        // When
        let sut = try StreamVideoOperator(framesPerSecond: framesPerSecond) { _ in }
        
        // Then
        #expect(sut.framesPerSecond == framesPerSecond)
    }
}

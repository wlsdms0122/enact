//
//  PointTests.swift
//  DigitCLITests
//
//  Created by JSilver on 8/16/26.
//

import Digit
import Testing
@testable import DigitCLI

@Suite("A point argument is exactly two numbers")
struct PointTests {
    // MARK: - Property
    // MARK: - Initializer
    // MARK: - Test
    @Test("two numbers are a point")
    func twoNumbersAreAPoint() throws {
        // When
        let point = try #require(Point(argument: "100,200"))
        
        // Then
        #expect(point.x == 100)
        #expect(point.y == 200)
    }
    
    @Test("an empty field is refused", arguments: [",100,200", "100,,200", "100,200,"])
    func anEmptyFieldIsRefused(argument: String) {
        // When / Then
        #expect(Point(argument: argument) == nil)
    }
}

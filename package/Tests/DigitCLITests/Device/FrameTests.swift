//
//  FrameTests.swift
//  DigitCLITests
//
//  Created by JSilver on 8/16/26.
//

import Digit
import Testing
@testable import DigitCLI

@Suite("A frame argument is exactly four numbers")
struct FrameTests {
    // MARK: - Property
    // MARK: - Initializer
    // MARK: - Test
    @Test("four numbers are a frame")
    func fourNumbersAreAFrame() {
        // When / Then
        #expect(Element.Frame(argument: "1,2,3,4") != nil)
    }
    
    @Test("an empty field is refused", arguments: [",1,2,3,4", "1,2,,3,4", "1,2,3,4,"])
    func anEmptyFieldIsRefused(argument: String) {
        // When / Then
        #expect(Element.Frame(argument: argument) == nil)
    }
}

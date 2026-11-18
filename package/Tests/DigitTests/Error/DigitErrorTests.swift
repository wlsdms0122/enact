//
//  DigitErrorTests.swift
//  DigitTests
//
//  Created by JSilver on 8/16/26.
//

import Testing
@testable import Digit

@Suite("A Digit error says what was refused")
struct DigitErrorTests {
    // MARK: - Property
    // MARK: - Initializer
    // MARK: - Test
    @Test("a value out of its interval names the field")
    func outOfIntervalNamesTheField() {
        // Given
        let sut = DigitError.outOfInterval(field: "position", value: 1e300, allowed: 0...1)
        
        // When / Then
        #expect(sut.description.contains("position"))
    }
    
    @Test("a character no keyboard types names the device's keyboards")
    func untypeableNamesTheKeyboards() {
        // Given
        let sut = DigitError.untypeableCharacter("é", keyboards: ["English (US)", "한국어"])
        
        // When / Then
        #expect(sut.description == "'é' is on no key of this device's keyboards (English (US), 한국어)")
    }
    
    @Test("what is typed is the argument's, where it is typed is the device's", arguments: [
        (DigitError.untypeableCharacter("é", keyboards: []), true),
        (DigitError.joinedJamo("ㅋ", after: "가"), true),
        (DigitError.noSoftwareKeyboard, false)
    ])
    func typingRefusalsNameWhoseFaultItIs(_ sut: DigitError, _ expected: Bool) {
        // When / Then
        #expect(sut.refusesArgument == expected)
    }
}

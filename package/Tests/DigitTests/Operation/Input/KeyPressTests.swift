//
//  KeyPressTests.swift
//  DigitTests
//
//  Created by JSilver on 8/16/26.
//

import Testing
@testable import Digit

@Suite("A key press is never a modifier")
struct KeyPressTests {
    // MARK: - Property
    // MARK: - Initializer
    // MARK: - Test
    @Test("a modifier code is refused", arguments: UInt32(224)...UInt32(231))
    func noModifierCodeCanBecomeAPress(code: UInt32) {
        // When / Then
        #expect(KeyPress(code: code) == nil)
    }
    
    @Test("the codes on either side of the modifier block press", arguments: [UInt32(223), 232])
    func theNeighboursPress(code: UInt32) {
        // When / Then
        #expect(KeyPress(code: code) != nil)
    }
    
    @Test("every modifier has a spelling of its own")
    func everyModifierIsSpelled() {
        // When / Then
        for name in ["shift", "control", "option", "command"] {
            #expect(Modifier(rawValue: name) != nil)
        }
    }
}

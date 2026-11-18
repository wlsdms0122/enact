//
//  KeyboardLayoutTests.swift
//  DigitTests
//
//  Created by JSilver on 8/16/26.
//

import Testing
@testable import Digit

@Suite("The keyboard layout turns characters and names into key presses")
struct KeyboardLayoutTests {
    // MARK: - Property
    // MARK: - Initializer
    // MARK: - Test
    @Test("a shifted character is its unshifted key with shift held")
    func shiftedCharactersCarryShift() throws {
        // Given
        let sut = KeyboardLayout()
        
        // When
        let capital = try #require(sut.press(for: "H"))
        let lower = try #require(sut.press(for: "h"))
        let bang = try #require(sut.press(for: "!"))
        let one = try #require(sut.press(for: "1"))
        
        // Then
        #expect(capital.code == lower.code)
        #expect(capital.shifted)
        #expect(!lower.shifted)
        #expect(bang.code == one.code)
        #expect(bang.shifted)
    }
    
    @Test("a digit names the number key, not the key code")
    func digitsNameTheNumberKey() throws {
        // Given
        let sut = KeyboardLayout()
        
        // When
        let four = try #require(sut.press(named: "4"))
        
        // Then
        #expect(four == sut.press(for: "4"))
        #expect(four.code != 4)
    }
    
    @Test(
        "no spelling of a modifier presses a key",
        arguments: ["shift", "control", "option", "command", "ctrl", "cmd", "alt"]
    )
    func noSpellingOfAModifierIsAKey(name: String) {
        // Given
        let sut = KeyboardLayout()
        
        // When / Then
        #expect(sut.press(named: name) == nil)
    }
    
    @Test("no named key is a modifier")
    func noNamedKeyIsAModifier() {
        // When / Then
        for (name, code) in KeyboardLayout.named {
            #expect(!(224...231).contains(code), "\(name) names a modifier")
        }
    }
    
    @Test("every named key and every printable character still presses")
    func everyKeyStillPresses() {
        // Given
        let sut = KeyboardLayout()
        
        // When / Then
        for name in KeyboardLayout.named.keys {
            #expect(sut.press(named: name) != nil, "\(name) is a key")
        }
        for scalar in UInt8(0x20)...UInt8(0x7E) {
            let character = Character(UnicodeScalar(scalar))
            
            #expect(sut.press(for: character) == sut.press(named: String(character)))
        }
    }
}

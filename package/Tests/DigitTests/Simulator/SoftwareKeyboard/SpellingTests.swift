//
//  SpellingTests.swift
//  DigitTests
//
//  Created by JSilver on 11/10/26.
//

import Testing
@testable import Digit

@Suite("A character is spelled as the keys that type it")
struct SpellingTests {
    // MARK: - Property
    // MARK: - Initializer
    // MARK: - Test
    @Test("a character is the key labeled with it, space the space key")
    func aCharacterIsItsKey() throws {
        // Given
        let dubeolsik = Dubeolsik()
        
        // When
        let letter = try Spelling("é", after: nil, inputMethod: dubeolsik)
        let space = try Spelling(" ", after: "a", inputMethod: dubeolsik)
        
        // Then
        guard case let .keys(keys, character, composed) = letter else {
            Issue.record("é is spelled as a key press")
            
            return
        }
        
        #expect(keys == [.character("é")])
        #expect(character == "é")
        #expect(!composed)
        
        guard case let .keys(spaceKeys, _, _) = space else {
            Issue.record("a space is spelled as a key press")
            
            return
        }
        
        #expect(spaceKeys == [.space])
    }
    
    @Test("a syllable is the keys the input method composes it from")
    func aSyllableIsComposed() throws {
        // Given
        let dubeolsik = Dubeolsik()
        
        // When
        let sut = try Spelling("닭", after: " ", inputMethod: dubeolsik)
        
        // Then
        guard case let .keys(keys, _, composed) = sut else {
            Issue.record("닭 is spelled as a key press")
            
            return
        }
        
        #expect(keys == "ㄷㅏㄹㄱ".map(SoftwareKey.character))
        #expect(composed)
    }
    
    @Test("a return and a tab are hardware key presses", arguments: [
        ("\n", KeyboardLayout.returnKey),
        ("\t", KeyboardLayout.tab)
    ] as [(Character, UInt32)])
    func returnAndTabArePressed(_ character: Character, _ code: UInt32) throws {
        // Given
        let dubeolsik = Dubeolsik()
        
        // When
        let sut = try Spelling(character, after: "a", inputMethod: dubeolsik)
        
        // Then
        guard case let .press(pressed) = sut else {
            Issue.record("\(character) is spelled as software keys")
            
            return
        }
        
        #expect(pressed == code)
    }
    
    @Test("a jamo the input method would compose into the character before it is refused")
    func aJoinedJamoIsRefused() {
        // Given
        let dubeolsik = Dubeolsik()
        
        // When / Then
        #expect(throws: DigitError.self) {
            try Spelling("ㅋ", after: "가", inputMethod: dubeolsik)
        }
    }
}

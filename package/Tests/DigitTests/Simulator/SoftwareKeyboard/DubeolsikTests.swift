//
//  DubeolsikTests.swift
//  DigitTests
//
//  Created by JSilver on 11/9/26.
//

import Testing
@testable import Digit

@Suite("The two-set input method spells Hangul as the labels of the keys that compose it")
struct DubeolsikTests {
    // MARK: - Property
    // MARK: - Initializer
    // MARK: - Test
    @Test("a syllable is spelled as its jamo, a compound in two keys and a tense one as its own key", arguments: [
        ("가", "ㄱㅏ"),
        ("닭", "ㄷㅏㄹㄱ"),
        ("꽉", "ㄲㅗㅏㄱ"),
        ("왔", "ㅇㅗㅏㅆ"),
        ("얘", "ㅇㅒ"),
        ("의", "ㅇㅡㅣ"),
        ("ㅋ", "ㅋ"),
        ("ㄸ", "ㄸ")
    ] as [(Character, String)])
    func syllablesAreTheirJamo(_ character: Character, _ expected: String) {
        // Given
        let sut = Dubeolsik()
        
        // When
        let spelling = sut.spelling(of: character)
        
        // Then
        #expect(spelling == Array(expected))
    }
    
    @Test("every syllable is spelled with two to five keys, each a jamo spelled as itself")
    func everySyllableIsSpelled() {
        // Given
        let sut = Dubeolsik()
        
        // When
        let spellings = (UInt32(0xAC00)...0xD7A3)
            .compactMap(Unicode.Scalar.init)
            .map { scalar in sut.spelling(of: Character(scalar)) }
        
        // Then
        #expect(spellings.count == 11_172)
        #expect(spellings.allSatisfy { spelling in spelling.map { (2...5).contains($0.count) } ?? false })
        #expect(spellings.compactMap(\.self).joined().allSatisfy { jamo in sut.spelling(of: jamo) == [jamo] })
    }
    
    @Test("a compound jamo alone, an archaic or a conjoining jamo and a letter are not Hangul it types", arguments: [
        "ㄳ", "ㅘ", "ㆍ", "\u{1100}", "a", "1"
    ] as [Character])
    func untypeableCharactersAreNil(_ character: Character) {
        // Given
        let sut = Dubeolsik()
        
        // When
        let spelling = sut.spelling(of: character)
        
        // Then
        #expect(spelling == nil)
    }
    
    @Test("a jamo joins the character before it as the keyboard composes them", arguments: [
        ("가", "ㅋ", true),
        ("오", "ㅏ", true),
        ("각", "ㅏ", true),
        ("각", "ㅅ", true),
        ("ㄱ", "ㅏ", true),
        ("ㅗ", "ㅏ", true),
        ("ㅡ", "ㅣ", true),
        ("가", "ㄸ", false),
        ("닭", "ㅅ", false),
        ("와", "ㅣ", false),
        ("ㄱ", "ㅅ", false),
        ("ㄹ", "ㅎ", false),
        ("ㅋ", "ㅋ", false),
        ("ㅏ", "ㅏ", false),
        ("가", "나", false),
        ("a", "ㅏ", false)
    ] as [(Character, Character, Bool)])
    func jamoJoinsAsComposed(_ previous: Character, _ jamo: Character, _ expected: Bool) {
        // Given
        let sut = Dubeolsik()
        
        // When
        let joins = sut.joins(jamo, after: previous)
        
        // Then
        #expect(joins == expected)
    }
}

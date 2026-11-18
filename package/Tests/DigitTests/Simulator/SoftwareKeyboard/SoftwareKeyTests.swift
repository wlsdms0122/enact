//
//  SoftwareKeyTests.swift
//  DigitTests
//
//  Created by JSilver on 11/10/26.
//

import Testing
@testable import Digit

@Suite("A software key is told by its identifier or its label")
struct SoftwareKeyTests {
    // MARK: - Property
    // MARK: - Initializer
    // MARK: - Test
    @Test("a key is what its identifier or its label names, whatever the layout's language", arguments: [
        (nil, "q", SoftwareKey.character("q")),
        (nil, "ㅃ", .character("ㅃ")),
        (nil, "ampersand", .character("&")),
        (nil, "앤드 기호", .character("&")),
        ("shift", "shift", .shift),
        ("more", "숫자", .more),
        ("more", "letters", .more),
        ("space", "space", .space),
        (nil, "Next keyboard", .nextKeyboard)
    ] as [(String?, String, SoftwareKey?)])
    func aKeyIsToldByIdentifierOrLabel(_ id: String?, _ label: String, _ expected: SoftwareKey?) {
        // Given
        let element = Element(id: id, label: label, role: .key, frame: Element.Frame(x: 0, y: 0, width: 10, height: 10))
        
        // When
        let sut = SoftwareKey(element)
        
        // Then
        #expect(sut == expected)
    }
    
    @Test("a key typing does not use is no software key", arguments: [
        ("delete", "삭제"),
        ("emoji", "Emoji"),
        ("dictation", "Dictate")
    ] as [(String, String)])
    func otherKeysAreNone(_ id: String, _ label: String) {
        // Given
        let element = Element(id: id, label: label, role: .key, frame: Element.Frame(x: 0, y: 0, width: 10, height: 10))
        
        // When
        let sut = SoftwareKey(element)
        
        // Then
        #expect(sut == nil)
    }
    
    @Test("a label of several characters names no character")
    func aLongLabelIsNoCharacter() {
        // Given
        let element = Element(label: ".com", role: .key, frame: Element.Frame(x: 0, y: 0, width: 10, height: 10))
        
        // When
        let sut = SoftwareKey(element)
        
        // Then
        #expect(sut == nil)
    }
}

//
//  InputTests.swift
//  EnactCLITests
//
//  Created by JSilver on 10/31/26.
//

import Foundation
import Testing
@testable import EnactCLI

@Suite("An input is a name and the text after its first equals sign")
struct InputTests {
    // MARK: - Property
    // MARK: - Initializer
    // MARK: - Test
    @Test("the text is kept as written, whatever it looks like", arguments: [
        ("pin=0412", "pin", "0412"),
        ("q=a=b", "q", "a=b"),
        ("n=1000", "n", "1000"),
        ("empty=", "empty", "")
    ])
    func theTextIsKept(_ argument: String, _ name: String, _ text: String) throws {
        // When
        let sut = try #require(Input(argument: argument))
        
        // Then
        #expect(sut.name == name)
        #expect(sut.text == text)
    }
    
    @Test("an argument with no name or no equals sign is no input", arguments: ["pin", "=1234", ""])
    func aNamelessArgumentIsNoInput(_ argument: String) {
        // When / Then
        #expect(Input(argument: argument) == nil)
    }
    
    // MARK: - Private
}

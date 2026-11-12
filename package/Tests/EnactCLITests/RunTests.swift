//
//  RunTests.swift
//  EnactCLITests
//
//  Created by JSilver on 10/31/26.
//

import Foundation
import Testing
@testable import EnactCLI

@Suite("run reads each input once")
struct RunTests {
    // MARK: - Property
    // MARK: - Initializer
    // MARK: - Test
    @Test("inputs are read by name, as their text")
    func inputsAreReadByName() throws {
        // Given
        let sut = try [given("pin=0412"), given("q=a=b")]
        
        // When
        let read = try Run.read(sut)
        
        // Then
        #expect(read == ["pin": "0412", "q": "a=b"])
    }
    
    @Test("a name given twice is refused", arguments: [["pin=111111", "pin=999999"], ["pin=1", "pin=1"]])
    func aNameGivenTwiceIsRefused(_ written: [String]) throws {
        // Given
        let sut = try written.map(given)
        
        // When / Then
        #expect(throws: (any Error).self) { try Run.read(sut) }
    }
    
    // MARK: - Private
    private func given(_ argument: String) throws -> Input {
        try #require(Input(argument: argument))
    }
}

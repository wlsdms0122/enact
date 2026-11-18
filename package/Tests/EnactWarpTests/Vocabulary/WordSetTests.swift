//
//  WordSetTests.swift
//  EnactWarpTests
//
//  Created by JSilver on 11/4/26.
//

import Foundation
import Testing
import Warp
@testable import Digit
@testable import EnactWarp

@Suite("A set of words is the enum a scenario writes")
struct WordSetTests {
    // MARK: - Property
    // MARK: - Initializer
    // MARK: - Test
    @Test("each word is a case carrying nothing, named as its spelling in lower camel case")
    func eachWordIsACase() throws {
        // Given
        let sut = WordSet<ContentSize>("Enact.ContentSize")
        
        // When
        guard case let .enum(cases, _, _) = sut.declaration else {
            Issue.record("\(sut.declaration) is no enum")
            
            return
        }
        
        // Then
        #expect(cases.count == ContentSize.allCases.count)
        #expect(cases["extraExtraLarge"] == [:])
        #expect(cases["small"] == [:])
    }
    
    @Test("a word crosses into a scenario as its case and back as it was", arguments: BiometricOutcome.allCases)
    func aWordRoundTrips(_ word: BiometricOutcome) throws {
        // Given
        let sut = WordSet<BiometricOutcome>("Enact.BiometricOutcome")
        
        // When
        let value = try sut.value(of: word)
        
        // Then
        #expect(sut.word(of: value) == word)
    }
    
    @Test("a case of another enum, or a value that is no case, is no word of the set")
    func anotherValueIsNoWord() throws {
        // Given
        let sut = WordSet<Appearance>("Enact.Appearance")
        
        // When
        let other = try WordSet<Contrast>("Enact.Contrast").value(of: .standard)
        
        // Then
        #expect(sut.word(of: other) == nil)
        #expect(sut.word(of: .string("dark")) == nil)
    }
}

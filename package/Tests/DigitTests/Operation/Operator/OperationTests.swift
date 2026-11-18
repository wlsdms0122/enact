//
//  OperationTests.swift
//  DigitTests
//
//  Created by JSilver on 8/16/26.
//

import Testing
@testable import Digit

@Suite("Operations are spelled the way the command line spells them")
struct OperationTests {
    // MARK: - Property
    // MARK: - Initializer
    // MARK: - Test
    @Test("every spelling is kebab case", arguments: Digit.Operation.allCases)
    func operationSpellingsAreKebabCase(sut: Digit.Operation) {
        // When / Then
        #expect(sut.rawValue.lowercased() == sut.rawValue)
    }
    
    @Test("a two-word operation is joined by a hyphen")
    func twoWordsAreHyphenated() {
        // When / Then
        #expect(Digit.Operation.describeUI.rawValue == "describe-ui")
    }
}

//
//  TerminalTableTests.swift
//  DigitCLITests
//
//  Created by JSilver on 8/16/26.
//

import Testing
@testable import DigitCLI

@Suite("A terminal table lines up columns by display width")
struct TerminalTableTests {
    // MARK: - Property
    private let sut = TerminalTable()
    
    // MARK: - Initializer
    // MARK: - Test
    @Test("Hangul takes two columns", arguments: [("abc", 3), ("토스", 4), ("토스뱅크 계좌", 13)])
    func hangulTakesTwoColumns(text: String, width: Int) {
        // When / Then
        #expect(sut.width(of: text) == width)
    }
    
    @Test(
        "padding counts columns, not characters",
        arguments: [("토스", "토스  "), ("ab", "ab    ")]
    )
    func paddingCountsColumns(text: String, padded: String) {
        // When / Then
        #expect(sut.padded(text, to: 6) == padded)
    }
    
    @Test("a cell already wider than the column is left as it is")
    func aWideCellIsNotCut() {
        // When / Then
        #expect(sut.padded("토스뱅크", to: 4) == "토스뱅크")
    }
    
    @Test("rows in mixed scripts line up")
    func mixedScriptsLineUp() {
        // When
        let table = sut.render([["토스", "one"], ["ab", "two"]])
        
        // Then
        #expect(table == "토스  one\nab    two")
    }
}

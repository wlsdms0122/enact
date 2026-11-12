//
//  WordSplitterTests.swift
//  DigitCLITests
//
//  Created by JSilver on 11/10/26.
//

import Testing
@testable import DigitCLI

@Suite("A line splits into words as a shell splits it")
struct WordSplitterTests {
    // MARK: - Property
    private let sut = WordSplitter()
    
    // MARK: - Initializer
    // MARK: - Test
    @Test(
        "blanks separate words, and quotes and escapes keep them together",
        arguments: [
            ("tap --point 200,400", ["tap", "--point", "200,400"]),
            ("  tap\t--point  1,2  ", ["tap", "--point", "1,2"]),
            ("", []),
            ("   ", []),
            (#"type-text "hello world""#, ["type-text", "hello world"]),
            ("type-text 'it is \"so\"'", ["type-text", #"it is "so""#]),
            (#"type-text "a \"b\" \\ c\d""#, ["type-text", #"a "b" \ c\d"#]),
            (#"type-text a\ b"#, ["type-text", "a b"]),
            (#"type-text pre"mid dle"'post'"#, ["type-text", "premid dlepost"]),
            (#"type-text "" ''"#, ["type-text", "", ""]),
            ("type-text 닭값 '꽃밭에 왔어요'", ["type-text", "닭값", "꽃밭에 왔어요"])
        ]
    )
    func lineSplitsIntoWords(line: String, words: [String]) throws {
        // When
        let split = try sut.split(line)
        
        // Then
        #expect(split == words)
    }
    
    @Test(
        "a quote never closed or a backslash at the end is refused",
        arguments: [#"type-text "open"#, "type-text 'open", #"type-text end\"#]
    )
    func unfinishedLineIsRefused(line: String) {
        // When / Then
        #expect(throws: (any Error).self) { try sut.split(line) }
    }
}

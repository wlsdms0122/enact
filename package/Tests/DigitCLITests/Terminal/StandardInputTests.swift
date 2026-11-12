//
//  StandardInputTests.swift
//  DigitCLITests
//
//  Created by JSilver on 8/16/26.
//

import Foundation
import Testing
@testable import DigitCLI

@Suite("Standard input is read as UTF-8 and never repaired")
struct StandardInputTests {
    // MARK: - Property
    private let sut = StandardInput()
    
    // MARK: - Initializer
    // MARK: - Test
    @Test("bytes that are not UTF-8 are refused, naming what was read")
    func malformedBytesAreRefused() throws {
        // Given
        let bad = Data([0x61, 0x62, 0xFF, 0xFE, 0x63, 0x64])
        
        // When
        let refusal = #expect(throws: (any Error).self) {
            try sut.text(bad, as: "clipboard text")
        }
        
        // Then
        let error = try #require(refusal)
        
        #expect("\(error)".contains("clipboard text"))
    }
    
    @Test("UTF-8 is read as it was sent", arguments: ["토스뱅크 송금", ""])
    func utf8IsReadAsSent(text: String) throws {
        // When / Then
        #expect(try sut.text(Data(text.utf8), as: "payload") == text)
    }
    
    @Test("lines are handed over one at a time, as bytes and without their newlines")
    func linesAreHandedOverOneAtATime() async throws {
        // Given
        let pipe = Pipe()
        pipe.fileHandleForWriting.write(Data([0x61, 0x0A, 0x0A, 0xFF, 0x0A, 0x62, 0x0D, 0x0A, 0x63]))
        try pipe.fileHandleForWriting.close()
        
        var lines: [Data] = []
        
        // When
        try await sut.forEachLine(of: pipe.fileHandleForReading) { line in lines.append(line) }
        
        // Then
        #expect(lines == [Data([0x61]), Data(), Data([0xFF]), Data([0x62, 0x0D]), Data([0x63])])
    }
}

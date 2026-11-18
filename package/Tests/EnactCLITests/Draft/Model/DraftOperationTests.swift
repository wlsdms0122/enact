//
//  DraftOperationTests.swift
//  EnactCLITests
//
//  Created by JSilver on 11/10/26.
//

import Foundation
import Testing
@testable import DigitCLI
@testable import EnactCLI

@Suite("A draft writes what a line does to the device, by the verb that does the same")
struct DraftOperationTests {
    // MARK: - Property
    // MARK: - Initializer
    // MARK: - Test
    @Test("a line that only reads the device is not written, and what no verb does is a comment")
    func readsAreNotWritten() throws {
        // Given
        let interpreter = SessionInterpreter(udid: "probe")
        
        // When
        let reads = try ["describe-ui", "describe-screen", "app-state --bundle-id a.b"].map { line in
            try DraftOperation(try #require(try interpreter.command(Data(line.utf8))), line: line)
        }
        let typed = try DraftOperation(try #require(try interpreter.command(Data("type-text wifi".utf8))), line: "type-text wifi")
        
        // Then
        #expect(reads.allSatisfy { operation in operation == nil })
        
        guard case let .call(call) = typed else {
            Issue.record("\(String(describing: typed)) is not a call")
            
            return
        }
        
        #expect(call.flow == "{ call: { procedure: type_text, arguments: { text: \"wifi\" } } }")
    }
    
    // MARK: - Private
}

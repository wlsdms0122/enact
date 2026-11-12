//
//  SessionReplyTests.swift
//  DigitCLITests
//
//  Created by JSilver on 11/10/26.
//

import ArgumentParser
import Digit
import Foundation
import Testing
@testable import DigitCLI

@Suite("A session answers each line with one line of JSON")
struct SessionReplyTests {
    // MARK: - Property
    // MARK: - Initializer
    // MARK: - Test
    @Test("a result, an empty answer and an error each encode as one object", arguments: [
        (SessionReply.result("background"), #"{"result":"background"}"#),
        (SessionReply.result(Empty()), #"{"result":null}"#),
        (SessionReply.result(["a": "b"]), #"{"result":{"a":"b"}}"#),
        (
            SessionReply.error(SessionFailure(.argumentRefused, "no command named 'x'")),
            #"{"error":{"detail":"no command named 'x'","kind":"argument_refused"}}"#
        )
    ])
    func replyEncodesAsOneObject(_ sut: SessionReply, _ expected: String) throws {
        // Given
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.sortedKeys]
        
        // When
        let encoded = String(decoding: try encoder.encode(sut), as: UTF8.self)
        
        // Then
        #expect(encoded == expected)
    }
    
    @Test("a failure is the line's when the command or the device refuses what it said", arguments: [
        (ValidationError("unknown key: hyper") as any Error, SessionFailure.Kind.argumentRefused),
        (DigitError.joinedJamo("ㅋ", after: "가"), .argumentRefused),
        (DigitError.targetNotFound(udid: "x"), .deviceRefused),
        (CancellationError(), .deviceRefused)
    ])
    func failureNamesWhoseFaultItIs(_ error: any Error, _ expected: SessionFailure.Kind) {
        // Given
        // When
        let sut = SessionFailure(performing: error)
        
        // Then
        #expect(sut.kind == expected)
    }
}

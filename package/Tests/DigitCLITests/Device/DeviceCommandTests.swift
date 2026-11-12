//
//  DeviceCommandTests.swift
//  DigitCLITests
//
//  Created by JSilver on 11/10/26.
//

import Foundation
import Testing
@testable import DigitCLI

@Suite("A device command takes standard input in reading, never in performing")
struct DeviceCommandTests {
    // MARK: - Property
    // MARK: - Initializer
    // MARK: - Test
    @Test("a command that would read - is refused where standard input is a session's lines", arguments: [
        ["--udid", "UDID", "-"],
        ["--udid", "UDID", "--bundle-id", "com.example", "--payload", "-"]
    ])
    func dashIsRefusedInASession(_ arguments: [String]) throws {
        // Given
        let sut: any DeviceCommand = arguments.contains("--payload")
            ? try PushNotification.parse(arguments)
            : try SetPasteboard.parse(arguments)
        
        // When / Then
        #expect(throws: (any Error).self) { _ = try sut.reading(.taken) }
    }
    
    @Test("a command given its text on the line reads nothing")
    func textOnTheLineIsKept() throws {
        // Given
        let sut = try SetPasteboard.parse(["--udid", "UDID", "hello"])
        
        // When
        let read = try sut.reading(.taken)
        
        // Then
        #expect(read.text == "hello")
    }
}

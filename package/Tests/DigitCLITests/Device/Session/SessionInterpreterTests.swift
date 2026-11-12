//
//  SessionInterpreterTests.swift
//  DigitCLITests
//
//  Created by JSilver on 11/10/26.
//

import Foundation
import Testing
@testable import DigitCLI

@Suite("A session reads each line as a command for the device it holds")
struct SessionInterpreterTests {
    // MARK: - Property
    // MARK: - Initializer
    // MARK: - Test
    @Test("a line is the command it names, for the session's device")
    func lineIsItsCommand() throws {
        // Given
        let sut = SessionInterpreter(udid: "UDID")
        
        // When
        let command = try sut.command(Data("tap --point 200,400".utf8))
        
        // Then
        let tap = try #require(command as? Tap)
        
        #expect(tap.target.udid == "UDID")
        #expect(tap.point.x == 200)
        #expect(tap.point.y == 400)
    }
    
    @Test("a blank line is no command")
    func blankLineIsNoCommand() throws {
        // Given
        let sut = SessionInterpreter(udid: "UDID")
        
        // When
        let command = try sut.command(Data("   ".utf8))
        
        // Then
        #expect(command == nil)
    }
    
    @Test("a line the session cannot take is the line's fault", arguments: [
        "fly --to moon",
        "tap --point nowhere",
        "tap --point 1,2 --udid OTHER",
        "boot"
    ])
    func refusedLineIsArgumentRefused(_ line: String) {
        // Given
        let sut = SessionInterpreter(udid: "UDID")
        
        // When
        let refusal = #expect(throws: SessionFailure.self) { _ = try sut.command(Data(line.utf8)) }
        
        // Then
        #expect(refusal?.kind == .argumentRefused)
    }
}

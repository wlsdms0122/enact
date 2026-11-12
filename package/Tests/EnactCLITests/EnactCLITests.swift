//
//  EnactCLITests.swift
//  EnactCLITests
//
//  Created by JSilver on 10/31/26.
//

import Foundation
import Testing
@testable import EnactCLI

@Suite("The root holds the scenario commands and the device's")
struct EnactCLITests {
    // MARK: - Property
    // MARK: - Initializer
    // MARK: - Test
    @Test("run, draft, check, graph and device are the commands there are")
    func theRootsCommands() {
        // When
        let sut = Set(EnactCLI.configuration.subcommands.compactMap { command in command.configuration.commandName })
        
        // Then
        #expect(sut == ["run", "draft", "check", "graph", "device"])
    }
    
    // MARK: - Private
}

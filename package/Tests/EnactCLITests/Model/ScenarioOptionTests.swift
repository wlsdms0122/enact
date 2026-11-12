//
//  ScenarioOptionTests.swift
//  EnactCLITests
//
//  Created by JSilver on 10/31/26.
//

import Foundation
import Testing
@testable import EnactCLI

@Suite("A scenario is named, pathed or read from stdin")
struct ScenarioOptionTests {
    // MARK: - Property
    // MARK: - Initializer
    // MARK: - Test
    @Test("a path answers to the name its text declares, or its file's name where it declares none, and a name to itself")
    func theEntryIsTheScenariosName() throws {
        // Given
        let directory = URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true)
            .appendingPathComponent("enact-option-\(UUID().uuidString)", isDirectory: true)
        defer { try? FileManager.default.removeItem(at: directory) }
        
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        try "name: Login\n".write(to: directory.appendingPathComponent("sign-in.yaml"), atomically: true, encoding: .utf8)
        try "uses: [Enact]\n".write(to: directory.appendingPathComponent("walk.yaml"), atomically: true, encoding: .utf8)
        
        // When
        let declared = try ScenarioOption.parse([directory.appendingPathComponent("sign-in.yaml").path]).entry()
        let undeclared = try ScenarioOption.parse([directory.appendingPathComponent("walk.yaml").path]).entry()
        let named = try ScenarioOption.parse(["Login", "--path", directory.path]).entry()
        
        // Then
        #expect(declared.name == "Login")
        #expect(undeclared.name == "walk")
        #expect(named.name == "Login")
    }
    
    @Test("a file run finds the scenarios under --path alone, not those beside it")
    func aFileRunSearchesOnlyThePath() throws {
        // Given
        let directory = URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true)
            .appendingPathComponent("enact-option-\(UUID().uuidString)", isDirectory: true)
        defer { try? FileManager.default.removeItem(at: directory) }
        
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        try "name: Checkout\n".write(to: directory.appendingPathComponent("checkout.yaml"), atomically: true, encoding: .utf8)
        try "name: Login\n".write(to: directory.appendingPathComponent("login.yaml"), atomically: true, encoding: .utf8)
        
        // When
        let entry = try ScenarioOption.parse([directory.appendingPathComponent("checkout.yaml").path]).entry()
        
        // Then
        #expect(try entry.store.sources().map(\.name) == ["Checkout"])
    }
    
    @Test("a name with nowhere to resolve, and a file not there, are refused up front", arguments: ["login", "not/there.yaml"])
    func anUnresolvableScenarioIsRefused(_ argument: String) throws {
        // Given
        let sut = try ScenarioOption.parse([argument])
        
        // When / Then
        #expect(throws: (any Error).self) { try sut.entry() }
    }
    
    // MARK: - Private
}

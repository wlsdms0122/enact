//
//  ObservationActionTests.swift
//  EnactWarpTests
//
//  Created by JSilver on 10/31/26.
//

import Foundation
import Testing
import Warp
@testable import EnactWarp

@Suite("screenshot saves what the screen shows in the out dir")
struct ObservationActionTests {
    // MARK: - Property
    // MARK: - Initializer
    // MARK: - Test
    @Test("a screenshot returns where it was saved")
    func aScreenshotReturnsItsPath() async throws {
        // Given
        let sut = try DeviceStage()
        let text = verbCall("screenshot", "{ name: home }", returns: "String")
        
        // When
        let result = try await EnactWarpTests.run(text, environment: sut.environment)
        
        // Then
        defer { try? FileManager.default.removeItem(at: sut.directory) }
        
        guard case let .string(path) = result else {
            Issue.record("\(result) is not a path")
            
            return
        }
        
        #expect(path == sut.directory.appendingPathComponent("out/home.png").path)
        #expect(FileManager.default.contents(atPath: path) == Data("png".utf8))
    }
    
    @Test("a name already taken gets a counter rather than writing over it")
    func aTakenNameGetsACounter() async throws {
        // Given
        let sut = try DeviceStage()
        let text = scenarioFile("""
        returns: Array<String>
        failing: anything
        body:
          - let: first
            value: { call: { procedure: screenshot, arguments: { name: home } } }
          - let: second
            value: { call: { procedure: screenshot, arguments: { name: home } } }
        result: [ { ref: first }, { ref: second } ]
        """)
        
        // When
        let result = try await EnactWarpTests.run(text, environment: sut.environment)
        
        // Then
        defer { try? FileManager.default.removeItem(at: sut.directory) }
        
        let out = sut.directory.appendingPathComponent("out")
        
        #expect(result == .array([.string(out.appendingPathComponent("home.png").path), .string(out.appendingPathComponent("home-1.png").path)]))
    }
    
    @Test("a name is a single file name", arguments: ["../escape", " ", "a/b"])
    func aNameIsAFileName(_ name: String) async throws {
        // Given
        let sut = try DeviceStage()
        
        // When
        let refusal = await #expect(throws: StepFailure.self) {
            _ = try await sut.run(verbCall("screenshot", "{ name: \"\(name)\" }", returns: "String"))
        }
        
        // Then
        #expect(try #require(refusal).kind == .argumentRefused)
    }
    
    // MARK: - Private
}

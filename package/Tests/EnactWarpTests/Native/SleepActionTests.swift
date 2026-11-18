//
//  SleepActionTests.swift
//  EnactWarpTests
//
//  Created by JSilver on 10/31/26.
//

import Foundation
import Testing
import Warp
@testable import EnactWarp

@Suite("sleep waits and says why")
struct SleepActionTests {
    // MARK: - Property
    // MARK: - Initializer
    // MARK: - Test
    @Test("a sleep with a reason returns nothing")
    func aSleepWithAReasonReturnsNothing() async throws {
        // Given
        let sut = scenarioFile("""
        failing: [argument_refused]
        result: { call: { procedure: sleep, arguments: { sec: 0, because: "the sheet slides up" } } }
        """)
        
        // When
        let result = try await run(sut)
        
        // Then
        #expect(result == .null)
    }
    
    @Test("a sleep is refused by the build without its reason")
    func aSleepWithoutAReasonDoesNotBuild() async throws {
        // Given
        let sut = scenarioFile("""
        failing: [argument_refused]
        result: { call: { procedure: sleep, arguments: { sec: 0 } } }
        """)
        
        // When
        let refusal = await #expect(throws: (any Error).self) {
            _ = try await run(sut)
        }
        
        // Then
        let error = try #require(refusal)
        
        #expect(!(error is StepFailure))
        #expect("\(error)".contains("because"), "\(error)")
    }
    
    @Test("a negative or endless wait, or an empty reason, is a refused argument", arguments: [
        "{ sec: -1, because: \"never\" }",
        "{ sec: 0, because: \"  \" }",
        "{ sec: 1e12, because: \"forever\" }"
    ])
    func aRefusedArgument(_ arguments: String) async throws {
        // Given
        let sut = scenarioFile("""
        failing: [argument_refused]
        result: { call: { procedure: sleep, arguments: \(arguments) } }
        """)
        
        // When
        let refusal = await #expect(throws: StepFailure.self) {
            _ = try await run(sut)
        }
        
        // Then
        let failure = try #require(refusal)
        
        #expect(failure.kind == .argumentRefused)
    }
    
    // MARK: - Private
}

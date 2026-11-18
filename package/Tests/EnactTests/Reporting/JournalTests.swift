//
//  JournalTests.swift
//  EnactTests
//
//  Created by JSilver on 10/31/26.
//

import Foundation
import Testing
import Warp
@testable import Digit
@testable import Enact
@testable import EnactWarp

@Suite("A journal records what the scenario's statements did")
struct JournalTests {
    // MARK: - Property
    // MARK: - Initializer
    // MARK: - Test
    @Test("a run that reaches the end is completed with what it returned, each statement under its name and the qualified name of the verb it called")
    func aRunThatEndsIsCompleted() async throws {
        // Given
        let sut = try DeviceStage()
        
        // When
        let report = try await sut.report(scenarioFile("""
        returns: String
        failing: anything
        body:
          - let: greet
            value: { call: { procedure: type_text, arguments: { text: hi } } }
          - let: said
            value: hello
        result: { ref: said }
        """))
        
        // Then
        #expect(report.outcome == .completed)
        #expect(report.result == ReportedValue(.string("hello"), enums: []))
        #expect(report.steps.map(\.path) == ["greet", "said"])
        #expect(report.steps.map(\.kind) == ["Enact.type_text", nil])
        #expect(report.steps.map(\.status) == [.ok, .ok])
        #expect(report.failures.isEmpty)
    }
    
    @Test("a value of an enum is written as its case, holding what it carries, wherever it stands")
    func aCaseIsWrittenAsItsCase() async throws {
        // Given
        let sut = try DeviceStage()
        
        // When
        let report = try await sut.report(scenarioFile("""
        returns: Array<Enact.Direction>
        body:
          - let: way
            type: Enact.Direction
            value: { case: up }
        result: [ { ref: way }, { case: left } ]
        """))
        
        // Then
        #expect(report.result?.description == #"[{"up":{}},{"left":{}}]"#)
        #expect(report.steps.first?.returned?.description == #"{"up":{}}"#)
    }
    
    @Test("a procedure's statements stand under the statement that called it")
    func aCallsChildrenWearItsAddress() async throws {
        // Given
        let sut = try DeviceStage()
        
        // When
        let report = try await sut.report("""
        uses: [Enact]
        procedures:
          main:
            access: public
            failing: anything
            body:
              - let: login
                value: { call: { procedure: signIn } }
          signIn:
            failing: anything
            body:
              - let: name
                value: { call: { procedure: type_text, arguments: { text: me } } }
        """)
        
        // Then
        #expect(report.steps.map(\.path) == ["login"])
        #expect(report.steps.first?.kind == "signIn")
        #expect(report.steps.first?.steps?.map(\.path) == ["login/name"])
    }
    
    @Test("a failure is charged where it happened, not where it passed through")
    func aFailureIsChargedWhereItHappened() async throws {
        // Given
        let sut = try DeviceStage()
        
        // When
        let report = try await sut.report("""
        uses: [Enact]
        procedures:
          main:
            access: public
            failing: anything
            body:
              - let: login
                value: { call: { procedure: signIn } }
          signIn:
            failing: anything
            body:
              - let: wait
                value: { call: { procedure: sleep, arguments: { sec: -1, because: never } } }
        """)
        
        // Then
        #expect(report.outcome == .aborted)
        #expect(report.failures == ["login/wait"])
        #expect(report.steps.first?.status == .failed)
        #expect(report.steps.first?.steps?.first?.failure?.kind == .argumentRefused)
        #expect(report.detail?.hasPrefix("argument_refused") == true)
    }
    
    @Test("a catch gives the charge back, and the record of what failed stays")
    func aCatchGivesTheChargeBack() async throws {
        // Given
        let sut = try DeviceStage()
        
        // When
        let report = try await sut.report(scenarioFile("""
        failing: anything
        body:
          - let: tried
            value:
              try:
                body:
                  - let: wait
                    value: { call: { procedure: sleep, arguments: { sec: -1, because: never } } }
                catch:
                  - let: noted
                    value: 1
        """))
        
        // Then
        #expect(report.outcome == .completed)
        #expect(report.failures.isEmpty)
        #expect(report.steps.first?.rescued == true)
        #expect(report.steps.first?.steps?.first?.status == .failed)
    }
    
    @Test("a repeat's rounds each hold the statements that ran in them")
    func aRepeatKeepsItsRounds() async throws {
        // Given
        let sut = try DeviceStage()
        
        // When
        let report = try await sut.report(scenarioFile("""
        failing: anything
        body:
          - let: settled
            value:
              call:
                procedure: repeat
                arguments:
                  timeout: 5
                  body: { closure: { returns: Int, body: [ { let: shown, value: 1 } ], result: { ref: shown } } }
                  until: { closure: { parameters: [ n: Int ], result: true } }
        """))
        
        // Then
        let rounds = try #require(report.steps.first?.rounds)
        
        #expect(report.steps.first?.kind == "Enact.repeat")
        #expect(rounds.map(\.index) == [0])
        #expect(rounds.first?.steps.map(\.path) == ["settled/shown"])
    }
    
    @Test("the run's failure kinds read from what Warp failed with", arguments: [
        ("{ abort: { format: no way, with: {} } }", StepFailure.Kind.aborted),
        ("{ as: { of: { ref: held }, type: Int } }", StepFailure.Kind.referenceUnfit)
    ])
    func aWarpFailureHasItsKind(_ expression: String, _ kind: StepFailure.Kind) async throws {
        // Given
        let sut = try DeviceStage()
        
        // When
        let report = try await sut.report(scenarioFile("""
        failing: anything
        body:
          - let: held
            type: Any
            value: text
          - value: \(expression)
        """))
        
        // Then
        #expect(report.outcome == .aborted)
        #expect(report.steps.last?.failure?.kind == kind)
    }
    
    @Test("the stream says what is happening while it happens")
    func theStreamSaysWhatHappens() async throws {
        // Given
        let sut = try DeviceStage()
        let heard = Heard()
        
        // When
        _ = try await sut.report(
            scenarioFile("""
            body:
              - let: one
                value: 1
            """),
            sink: { event in heard.append("\(event.event) \(event.path ?? "")") }
        )
        
        // Then
        #expect(heard.events == ["run_begin ", "step_begin one", "step_end one", "run_end "])
    }
    
    // MARK: - Private
}

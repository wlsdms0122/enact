//
//  ScenarioRunnerTests.swift
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

@Suite("A runner refuses what cannot run, runs the rest and reports it")
struct ScenarioRunnerTests {
    private final class DeafBackend: DeviceBackend, @unchecked Sendable {
        // MARK: - Property
        let info = DeviceInfo(udid: "udid-deaf", name: "stub", osVersion: "iOS 26.0", state: .booted)
        
        var dispatchTable: DispatchTable { DispatchTable([]) }
        
        // MARK: - Initializer
        // MARK: - Public
        // MARK: - Private
    }
    
    // MARK: - Property
    private let threeSteps = scenarioFile("""
    failing: anything
    body:
      - let: one
        value: { call: { procedure: type_text, arguments: { text: a } } }
      - let: two
        value: { call: { procedure: type_text, arguments: { text: b } } }
      - let: three
        value: { call: { procedure: type_text, arguments: { text: c } } }
    """)
    
    // MARK: - Initializer
    // MARK: - Test
    @Test("--stop-at ends the run after the statement it names")
    func aStopEndsTheRun() async throws {
        // Given
        let sut = try DeviceStage()
        
        // When
        let report = try await sut.report(threeSteps, stop: .after("two"))
        
        // Then
        #expect(report.outcome == .completed)
        #expect(report.stop?.reached == true)
        #expect(report.failures.isEmpty)
        #expect(sut.backend.performed.count == 2)
    }
    
    @Test("--stop-before ends the run before the statement it names, which stays out of the record")
    func aStopBeforeEndsTheRunBeforeIt() async throws {
        // Given
        let sut = try DeviceStage()
        
        // When
        let report = try await sut.report(threeSteps, stop: .before("two"))
        
        // Then
        #expect(report.outcome == .completed)
        #expect(report.stop?.reached == true)
        #expect(report.stop?.before == true)
        #expect(report.failures.isEmpty)
        #expect(report.steps.map(\.path) == ["one"])
        #expect(sut.backend.performed.count == 1)
    }
    
    @Test("a stop before a statement that calls a procedure runs nothing of the procedure")
    func aStopBeforeACallRunsNothingOfIt() async throws {
        // Given
        let sut = try DeviceStage()
        let text = """
        uses: [Enact]
        procedures:
          main:
            access: public
            failing: anything
            body:
              - let: pay
                value: { call: { procedure: send } }
          send:
            failing: anything
            body:
              - let: amount
                value: { call: { procedure: type_text, arguments: { text: a } } }
        """
        
        // When
        let report = try await sut.report(text, stop: .before("pay"))
        
        // Then
        #expect(report.outcome == .completed)
        #expect(report.stop?.reached == true)
        #expect(report.steps.isEmpty)
        #expect(sut.backend.performed.isEmpty)
    }
    
    @Test("a stop in a branch nobody takes never arrives, and the run goes to its end")
    func aStopInAnUntakenBranchNeverArrives() async throws {
        // Given
        let sut = try DeviceStage()
        let text = scenarioFile("""
        failing: anything
        body:
          - value:
              cases:
                - when: false
                  then:
                    - let: hidden
                      value: { call: { procedure: type_text, arguments: { text: a } } }
          - let: after
            value: { call: { procedure: type_text, arguments: { text: b } } }
        """)
        
        // When
        let report = try await sut.report(text, stop: .after("[0]/hidden"))
        
        // Then
        #expect(report.outcome == .completed)
        #expect(report.stop?.reached == false)
        #expect(sut.backend.performed.count == 1)
    }
    
    @Test(
        "a stop at an address the scenario's statement tree does not have is refused before the run",
        arguments: ["tow", "[9]", "/two", "two/", "two/one"]
    )
    func anUnknownStopIsRefused(_ address: String) async throws {
        // Given
        let sut = try DeviceStage()
        
        // When
        let report = try await sut.report(threeSteps, stop: .after(address))
        
        // Then
        #expect(report.outcome == .refused)
        #expect(report.refused == .stopUnknown)
        #expect(sut.backend.performed.isEmpty)
    }
    
    @Test("a stop written short of its address is refused with the addresses of the statement it names")
    func aShortStopNamesWhereItStands() async throws {
        // Given
        let sut = try DeviceStage()
        let text = scenarioFile("""
        failing: anything
        body:
          - let: outer
            value:
              try:
                body:
                  - let: inner
                    value: { call: { procedure: type_text, arguments: { text: a } } }
                catch:
                  - let: caught
                    value: 1
        """)
        
        // When
        let report = try await sut.report(text, stop: .after("inner"))
        
        // Then
        #expect(report.refused == .stopUnknown)
        #expect(report.detail?.hasSuffix("Statements named 'inner': outer/inner") == true, "\(report.detail ?? "")")
        #expect(sut.backend.performed.isEmpty)
    }
    
    @Test("a device that does none of what the scenario can ask is refused before the run")
    func anUnsupportedDeviceIsRefused() async throws {
        // Given
        let directory = URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true)
            .appendingPathComponent("enact-test-\(UUID().uuidString)", isDirectory: true)
        let lock = DeviceLock(directory: directory)
        let device = Device(backend: DeafBackend(), lock: lock)
        
        defer { try? FileManager.default.removeItem(at: directory) }
        
        // When
        let report = await ScenarioRunner(vocabulary: try EnactVocabulary.shipped.get()).run(
            try await image(of: threeSteps),
            entry: entry,
            scenario: "test",
            statements: StatementTree(procedures: try document(of: threeSteps).procedures, entry: entry),
            device: device,
            lock: lock,
            outputDirectory: OutputDirectory(url: directory)
        )
        
        // Then
        #expect(report.refused == .unsupportedDevice)
        #expect(report.detail?.contains("type_text") == true)
    }
    
    @Test("a device another run holds is refused")
    func aBusyDeviceIsRefused() async throws {
        // Given
        let sut = try DeviceStage()
        let lock = DeviceLock(directory: sut.directory.appendingPathComponent("held"))
        
        // When
        let report = try await lock.withExclusiveAccess(to: "udid-enact") {
            try await sut.report(threeSteps, lock: lock)
        }
        
        // Then
        #expect(report.refused == .deviceBusy)
        #expect(sut.backend.performed.isEmpty)
    }
    
    @Test("a failed statement leaves what the screen showed, and a video the run landed is listed")
    func aRunLeavesItsEvidenceAndVideos() async throws {
        // Given
        let sut = try DeviceStage()
        let text = scenarioFile("""
        failing: anything
        body:
          - let: recorded
            value: { call: { procedure: record, arguments: { name: walk, body: { closure: { returns: Int, result: 1 } } } } }
          - let: wait
            value: { call: { procedure: sleep, arguments: { sec: -1, because: never } } }
        """)
        
        // When
        let report = try await sut.report(text)
        
        // Then
        let evidence = try #require(report.steps.last?.evidence)
        
        #expect(report.recordings.map { path in URL(fileURLWithPath: path).lastPathComponent } == ["walk.mp4"])
        #expect(evidence.screenshot.map { path in URL(fileURLWithPath: path).lastPathComponent } == "failed-wait.png")
        #expect(evidence.look.map { path in URL(fileURLWithPath: path).lastPathComponent } == "failed-wait.json")
    }
    
    @Test("a failed statement's evidence sums up the screen: its headings, buttons and fields, by label or else value")
    func evidenceSumsUpTheScreen() async throws {
        // Given
        let sut = try DeviceStage(elements: [
            Element(label: "Transfer", role: .heading, frame: Element.Frame(x: 0, y: 0, width: 400, height: 40)),
            Element(label: "Amount", value: "0", role: .field, frame: Element.Frame(x: 0, y: 60, width: 400, height: 40)),
            Element(label: "", value: "Memo", role: .field, frame: Element.Frame(x: 0, y: 110, width: 400, height: 40)),
            Element(label: "Send\nnow", role: .button, frame: Element.Frame(x: 0, y: 700, width: 400, height: 40)),
            Element(label: "Balance", role: .text, frame: Element.Frame(x: 0, y: 160, width: 400, height: 20))
        ])
        let text = scenarioFile("""
        failing: anything
        body:
          - let: wait
            value: { call: { procedure: sleep, arguments: { sec: -1, because: never } } }
        """)
        
        // When
        let report = try await sut.report(text)
        
        // Then
        let summary = try #require(report.steps.last?.evidence?.summary)
        
        #expect(summary.headings == ["Transfer"])
        #expect(summary.buttons == ["Send\nnow"])
        #expect(summary.fields == ["Amount", "Memo"])
        #expect(report.plain.contains("screen  heading 'Transfer' · button 'Send now' · field 'Amount', 'Memo'"), "\(report.plain)")
    }
    
    @Test("a failure a try caught leaves no evidence, unless the run keeps it", arguments: [false, true])
    func aCaughtFailureLeavesNoEvidence(_ keeps: Bool) async throws {
        // Given
        let sut = try DeviceStage()
        let text = scenarioFile("""
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
        """)
        
        // When
        let report = try await sut.report(text, keepsCaughtEvidence: keeps)
        
        // Then
        let tried = try #require(report.steps.first)
        let wait = try #require(tried.steps?.first { step in step.id == "wait" })
        
        #expect(tried.rescued == true)
        #expect(wait.status == .failed)
        #expect((wait.evidence != nil) == keeps)
    }
    
    @Test("a video the run lost is reported lost, with why, and not listed with the videos it landed")
    func aLostVideoIsInTheReport() async throws {
        // Given
        let sut = try DeviceStage(closing: NSError(domain: "FBSimulatorError", code: 2))
        let failing = "{ call: { procedure: sleep, arguments: { sec: -1, because: never } } }"
        let text = scenarioFile("""
        failing: anything
        body:
          - let: recorded
            value: { call: { procedure: record, arguments: { name: walk, body: { closure: { failing: anything, result: \(failing) } } } } }
        """)
        
        // When
        let report = try await sut.report(text)
        
        // Then
        #expect(report.recordings.isEmpty)
        #expect(report.lostRecordings.map { lost in URL(fileURLWithPath: lost.path).lastPathComponent } == ["walk.mp4"])
        #expect(report.plain.contains("lost      "), "\(report.plain)")
    }
    
    @Test("a report written into the out dir says where it is")
    func aWrittenReportSaysWhere() async throws {
        // Given
        let directory = URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true)
            .appendingPathComponent("enact-test-\(UUID().uuidString)", isDirectory: true)
        let sut = ScenarioRunner(vocabulary: try EnactVocabulary.shipped.get())
        let report = Report.refusing(.loadFailed, "nothing", scenario: "test")
        
        defer { try? FileManager.default.removeItem(at: directory) }
        
        // When
        let written = await sut.written(report, in: OutputDirectory(url: directory))
        
        // Then
        let path = try #require(written.reportPath)
        
        #expect(path == directory.appendingPathComponent("report.json").path)
        #expect(FileManager.default.fileExists(atPath: path))
    }
    
    // MARK: - Private
}

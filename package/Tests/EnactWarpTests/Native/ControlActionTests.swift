//
//  ControlActionTests.swift
//  EnactWarpTests
//
//  Created by JSilver on 10/31/26.
//

import Foundation
import Testing
import Warp
@testable import Digit
@testable import EnactWarp

@Suite("record, record_log and repeat run a body and return what it returned")
struct ControlActionTests {
    // MARK: - Property
    // MARK: - Initializer
    // MARK: - Test
    @Test("a record takes video while its body runs, lands it in the out dir and returns the body's result")
    func aRecordReturnsItsBody() async throws {
        // Given
        let sut = try DeviceStage()
        let text = verbCall("record", "{ name: walk, body: { closure: { returns: String, result: done } } }", returns: "String")
        
        // When
        let result = try await EnactWarpTests.run(text, environment: sut.environment)
        
        // Then
        defer { try? FileManager.default.removeItem(at: sut.directory) }
        
        #expect(result == .string("done"))
        #expect(FileManager.default.fileExists(atPath: sut.directory.appendingPathComponent("out/walk.mp4").path))
        #expect(sut.backend.performed.contains { operation in operation is RecordVideoOperator })
    }
    
    @Test("a record inside a record is refused, since a device records one video at a time")
    func aRecordInsideARecordIsRefused() async throws {
        // Given
        let sut = try DeviceStage()
        let inner = "{ call: { procedure: record, arguments: { body: { closure: { returns: Int, result: 1 } } } } }"
        let text = verbCall("record", "{ body: { closure: { returns: Int, result: \(inner) } } }", returns: "Int")
        
        // When
        let refusal = await #expect(throws: StepFailure.self) {
            _ = try await sut.run(text)
        }
        
        // Then
        #expect(try #require(refusal).kind == .recordingFailed)
    }
    
    @Test("a record_log streams the log filtered by its predicate while its body runs, lands it in the out dir and returns the body's result")
    func aRecordLogReturnsItsBody() async throws {
        // Given
        let sut = try DeviceStage()
        let arguments = "{ name: walk, predicate: 'process == \"Preferences\"', body: { closure: { returns: String, result: done } } }"
        let text = verbCall("record_log", arguments, returns: "String")
        
        defer { try? FileManager.default.removeItem(at: sut.directory) }
        
        // When
        let result = try await EnactWarpTests.run(text, environment: sut.environment)
        
        // Then
        let streamed = sut.backend.performed.compactMap { operation in operation as? RecordLogOperator }
        
        #expect(result == .string("done"))
        #expect(streamed.map(\.predicate) == ["process == \"Preferences\""])
        #expect(sut.environment.recordings.landed.map { path in URL(fileURLWithPath: path).lastPathComponent } == ["walk.log"])
        #expect(FileManager.default.fileExists(atPath: sut.directory.appendingPathComponent("out/walk.log").path))
    }
    
    @Test("a record_log inside a record runs, since a log streams beside a video")
    func aRecordLogInsideARecordRuns() async throws {
        // Given
        let sut = try DeviceStage()
        let inner = "{ call: { procedure: record_log, arguments: { body: { closure: { returns: Int, result: 1 } } } } }"
        let text = verbCall("record", "{ body: { closure: { returns: Int, result: \(inner) } } }", returns: "Int")
        
        defer { try? FileManager.default.removeItem(at: sut.directory) }
        
        // When
        let result = try await EnactWarpTests.run(text, environment: sut.environment)
        
        // Then
        #expect(result == .int(1))
        #expect(sut.environment.recordings.landed.map { path in URL(fileURLWithPath: path).lastPathComponent } == ["log.log", "video.mp4"])
    }
    
    @Test("what the body failed with goes on as it was")
    func aBodyFailureGoesOn() async throws {
        // Given
        let sut = try DeviceStage()
        let failing = "{ call: { procedure: sleep, arguments: { sec: -1, because: never } } }"
        let text = verbCall("record", "{ body: { closure: { failing: anything, result: \(failing) } } }")
        
        // When
        let refusal = await #expect(throws: StepFailure.self) {
            _ = try await sut.run(text)
        }
        
        // Then
        #expect(try #require(refusal).kind == .argumentRefused)
    }
    
    @Test("a video whose body failed is still listed and kept, since a failed run is the one a video is wanted for")
    func aFailedBodysVideoIsListed() async throws {
        // Given
        let sut = try DeviceStage()
        let failing = "{ call: { procedure: sleep, arguments: { sec: -1, because: never } } }"
        let text = verbCall("record", "{ name: walk, body: { closure: { failing: anything, result: \(failing) } } }")
        
        defer { try? FileManager.default.removeItem(at: sut.directory) }
        
        // When
        let refusal = await #expect(throws: StepFailure.self) {
            _ = try await EnactWarpTests.run(text, environment: sut.environment)
        }
        
        // Then
        let listed = sut.environment.recordings.landed
        
        #expect(try #require(refusal).kind == .argumentRefused)
        #expect(listed.map { path in URL(fileURLWithPath: path).lastPathComponent } == ["walk.mp4"])
        #expect(listed.allSatisfy { path in FileManager.default.fileExists(atPath: path) })
    }
    
    @Test("a video lost after its body failed is logged lost, and the body's failure goes on as it was")
    func aLostVideoIsLoggedLost() async throws {
        // Given
        let sut = try DeviceStage(closing: NSError(domain: "FBSimulatorError", code: 2))
        let failing = "{ call: { procedure: sleep, arguments: { sec: -1, because: never } } }"
        let text = verbCall("record", "{ name: walk, body: { closure: { failing: anything, result: \(failing) } } }")
        
        defer { try? FileManager.default.removeItem(at: sut.directory) }
        
        // When
        let refusal = await #expect(throws: StepFailure.self) {
            _ = try await EnactWarpTests.run(text, environment: sut.environment)
        }
        
        // Then
        let failure = try #require(refusal)
        let lost = sut.environment.recordings.lost
        
        #expect(failure.kind == .argumentRefused)
        #expect(!failure.detail.contains("closing the recording"), "\(failure.detail)")
        #expect(sut.environment.recordings.landed.isEmpty)
        #expect(lost.map { lost in URL(fileURLWithPath: lost.path).lastPathComponent } == ["walk.mp4"])
        #expect(lost.allSatisfy { lost in lost.reason.contains("closing the recording") })
        #expect(lost.allSatisfy { lost in !FileManager.default.fileExists(atPath: lost.path) })
    }
    
    @Test("a video lost under a body that went well is recording_failed, and logged lost")
    func aLostVideoUnderAGoodBodyIsRecordingFailed() async throws {
        // Given
        let sut = try DeviceStage(closing: NSError(domain: "FBSimulatorError", code: 2))
        let text = verbCall("record", "{ name: walk, body: { closure: { returns: Int, result: 1 } } }", returns: "Int")
        
        defer { try? FileManager.default.removeItem(at: sut.directory) }
        
        // When
        let refusal = await #expect(throws: StepFailure.self) {
            _ = try await EnactWarpTests.run(text, environment: sut.environment)
        }
        
        // Then
        #expect(try #require(refusal).kind == .recordingFailed)
        #expect(sut.environment.recordings.landed.isEmpty)
        #expect(sut.environment.recordings.lost.count == 1)
    }
    
    @Test("a recorder that cannot start is recording_failed, and leaves no video")
    func aRecorderThatCannotStartLeavesNoVideo() async throws {
        // Given
        let sut = try DeviceStage(failure: NSError(domain: "FBSimulatorError", code: 1))
        let text = verbCall("record", "{ name: walk, body: { closure: { returns: Int, result: 1 } } }", returns: "Int")
        
        defer { try? FileManager.default.removeItem(at: sut.directory) }
        
        // When
        let refusal = await #expect(throws: StepFailure.self) {
            _ = try await EnactWarpTests.run(text, environment: sut.environment)
        }
        
        // Then
        #expect(try #require(refusal).kind == .recordingFailed)
        #expect(sut.environment.recordings.landed.isEmpty)
        #expect(!FileManager.default.fileExists(atPath: sut.directory.appendingPathComponent("out/walk.mp4").path))
    }
    
    @Test("a repeat returns the round until held of")
    func aRepeatReturnsTheRoundThatHeld() async throws {
        // Given
        let text = verbCall(
            "repeat",
            "{ timeout: 5, body: { closure: { returns: Int, result: 7 } }, "
                + "until: { closure: { parameters: [ n: Int ], result: { of: { ref: n }, is: 7 } } } }",
            returns: "Int"
        )
        
        // When
        let result = try await run(text)
        
        // Then
        #expect(result == .int(7))
    }
    
    @Test("a repeat out of time is timed_out")
    func aRepeatOutOfTimeIsTimedOut() async throws {
        // Given
        let text = verbCall(
            "repeat",
            "{ timeout: 0.3, body: { closure: { returns: Int, result: 7 } }, "
                + "until: { closure: { parameters: [ n: Int ], result: false } } }",
            returns: "Int"
        )
        
        // When
        let refusal = await #expect(throws: StepFailure.self) {
            _ = try await run(text)
        }
        
        // Then
        #expect(try #require(refusal).kind == .timedOut)
    }
    
    @Test("with debounce, what held must come back the same for that long")
    func aDebouncedRepeatWaits() async throws {
        // Given
        let text = verbCall(
            "repeat",
            "{ timeout: 5, debounce: 0.3, body: { closure: { returns: Int, result: 7 } }, "
                + "until: { closure: { parameters: [ n: Int ], result: true } } }",
            returns: "Int"
        )
        let clock = ContinuousClock()
        let start = clock.now
        
        // When
        let result = try await run(text)
        
        // Then
        #expect(result == .int(7))
        #expect(clock.now - start >= .milliseconds(300))
    }
    
    @Test("a repeat needs seconds to spend", arguments: ["{ timeout: 0", "{ timeout: 1, debounce: 0"])
    func aRepeatNeedsSeconds(_ opening: String) async throws {
        // Given
        let text = verbCall(
            "repeat",
            "\(opening), body: { closure: { returns: Int, result: 7 } }, until: { closure: { parameters: [ n: Int ], result: true } } }",
            returns: "Int"
        )
        
        // When
        let refusal = await #expect(throws: StepFailure.self) {
            _ = try await run(text)
        }
        
        // Then
        #expect(try #require(refusal).kind == .argumentRefused)
    }
    
    // MARK: - Private
}

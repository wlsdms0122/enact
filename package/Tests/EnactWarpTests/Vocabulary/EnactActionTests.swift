//
//  EnactActionTests.swift
//  EnactWarpTests
//
//  Created by JSilver on 10/31/26.
//

import Foundation
import Testing
import Warp
@testable import Digit
@testable import EnactWarp

@Suite("A device verb says what the device refused as a step failure of its kind")
struct EnactActionTests {
    private final class DeafBackend: DeviceBackend, @unchecked Sendable {
        // MARK: - Property
        let info = DeviceInfo(udid: "udid-deaf", name: "stub", osVersion: "iOS 26.0", state: .booted)
        
        var dispatchTable: DispatchTable { DispatchTable([]) }
        
        // MARK: - Initializer
        // MARK: - Public
        // MARK: - Private
    }
    
    // MARK: - Property
    // MARK: - Initializer
    // MARK: - Test
    @Test("what the device fails at is device_refused, and what it refuses of an argument is argument_refused", arguments: [
        (DigitError.commandFailed(command: "simctl", message: "no"), StepFailure.Kind.deviceRefused),
        (DigitError.untypeableCharacter("é", keyboards: ["English (US)"]), StepFailure.Kind.argumentRefused)
    ])
    func aDigitErrorIsAKind(_ error: DigitError, _ kind: StepFailure.Kind) async throws {
        // Given
        let sut = try DeviceStage(failure: error)
        
        // When
        let refusal = await #expect(throws: StepFailure.self) {
            _ = try await sut.run(verbCall("type_text", "{ text: hello }"))
        }
        
        // Then
        #expect(try #require(refusal).kind == kind)
    }
    
    @Test("an interruption is a cancellation, which no catch in a scenario takes")
    func anInterruptionIsACancellation() async throws {
        // Given
        let sut = try DeviceStage(failure: DigitError.interrupted)
        
        // When / Then
        await #expect(throws: CancellationError.self) {
            _ = try await sut.run(verbCall("type_text", "{ text: hello }"))
        }
    }
    
    @Test("a device that cannot do the operation refuses it")
    func aMissingCapabilityIsADeviceRefusal() async throws {
        // Given
        let directory = URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true)
            .appendingPathComponent("enact-test-\(UUID().uuidString)", isDirectory: true)
        let environment = EnactEnvironment(
            device: Device(backend: DeafBackend(), lock: DeviceLock(directory: directory)),
            outputDirectory: OutputDirectory(url: directory)
        )
        
        // When
        let refusal = await #expect(throws: StepFailure.self) {
            _ = try await run(verbCall("type_text", "{ text: hello }"), environment: environment)
        }
        
        // Then
        #expect(try #require(refusal).kind == .deviceRefused)
    }
    
    @Test("a device verb in a run with no device is refused, and not as a failure a scenario takes")
    func aRunWithoutADeviceRefusesDeviceVerbs() async throws {
        // When
        let refusal = await #expect(throws: (any Error).self) {
            _ = try await run(verbCall("type_text", "{ text: hello }"))
        }
        
        // Then
        let error = try #require(refusal)
        
        #expect(!(error is any RecoverableFailure), "\(error)")
        #expect("\(error)".contains("drives a device"), "\(error)")
    }
    
    @Test("a scenario's catch takes a refusal by its kind")
    func aCatchTakesTheKind() async throws {
        // Given
        let sut = try DeviceStage(failure: DigitError.commandFailed(command: "simctl", message: "no"))
        let text = scenarioFile("""
        returns: String
        body:
          - var: kind
            type: String
            value: none
          - let: failure
            value:
              try:
                body:
                  - value: { call: { procedure: type_text, arguments: { text: hello } } }
                catch:
                  - set: kind
                    value: { ref: failure.type }
        result: { ref: kind }
        """)
        
        // When
        let result = try await sut.run(text)
        
        // Then
        #expect(result == .string("device_refused"))
    }
    
    // MARK: - Private
}

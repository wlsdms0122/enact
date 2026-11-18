//
//  ApplicationActionTests.swift
//  EnactWarpTests
//
//  Created by JSilver on 10/31/26.
//

import Foundation
import Testing
import Warp
@testable import Digit
@testable import EnactWarp

@Suite("Application verbs reach the app their bundle id names")
struct ApplicationActionTests {
    // MARK: - Property
    // MARK: - Initializer
    // MARK: - Test
    @Test("each application verb hands the device the operation its arguments say", arguments: [
        (
            "launch_app",
            "{ bundle_id: com.example.app, args: [-reset], locale: ko_KR }",
            "LaunchAppOperator(bundleID: \"com.example.app\", arguments: [\"-reset\"], environment: [:], locale: Optional(\"ko_KR\"), language: nil)"
        ),
        ("terminate_app", "{ bundle_id: com.example.app }", "TerminateAppOperator(bundleID: \"com.example.app\")"),
        ("uninstall_app", "{ bundle_id: com.example.app }", "UninstallAppOperator(bundleID: \"com.example.app\")"),
        ("install_app", "{ path: /tmp/App.app }", "InstallAppOperator(path: \"/tmp/App.app\")"),
        ("open_url", "{ url: \"myapp://home\" }", "OpenURLOperator(url: myapp://home)"),
        (
            "push_notification",
            "{ bundle_id: com.example.app, payload: { dictionary: { aps: { dictionary: { alert: Hi, badge: 1 } }, deeplink: \"myapp://home\" } } }",
            "PushNotificationOperator(bundleID: \"com.example.app\", payload: \"{\\\"aps\\\":{\\\"alert\\\":\\\"Hi\\\",\\\"badge\\\":1},\\\"deeplink\\\":\\\"myapp://home\\\"}\")"
        )
    ])
    func eachVerbHandsTheDeviceItsOperation(_ procedure: String, _ arguments: String, _ expected: String) async throws {
        // Given
        let sut = try DeviceStage()
        
        // When
        let result = try await sut.run(verbCall(procedure, arguments))
        
        // Then
        #expect(result == .null)
        #expect(sut.backend.performed.map(String.init(describing:)) == [expected])
    }
    
    @Test("app_state asks the device where the app stands and returns it as an Enact.AppState case")
    func appStateReturnsTheState() async throws {
        // Given
        let sut = try DeviceStage()
        
        // When
        let result = try await sut.run(verbCall("app_state", "{ bundle_id: com.example.app }", returns: "Enact.AppState"))
        
        // Then
        #expect(result == (try EnactVocabulary.appState.value(of: .foreground)))
        #expect(sut.backend.performed.map(String.init(describing:)) == ["AppStateOperator(bundleID: \"com.example.app\")"])
    }
    
    @Test("an app verb is refused by the build without a bundle id")
    func anAppVerbNeedsItsBundleID() async throws {
        // Given
        let sut = try DeviceStage()
        
        // When / Then
        await #expect(throws: (any Error).self) {
            _ = try await sut.run(verbCall("terminate_app", "{}"))
        }
        #expect(sut.backend.performed.isEmpty)
    }
    
    @Test("a payload holding what JSON does not write is refused at the keys that lead to it")
    func aPayloadJSONDoesNotWriteIsRefused() async throws {
        // Given
        let sut = try DeviceStage()
        
        // When
        let refusal = await #expect(throws: StepFailure.self) {
            _ = try await sut.run(scenarioFile("""
            failing: anything
            body:
              - let: seen
                value: { call: { procedure: look } }
            result: { call: { procedure: push_notification, arguments: { bundle_id: com.example.app, payload: { dictionary: { aps: { ref: seen } } } } } }
            """))
        }
        
        // Then
        #expect(try #require(refusal).kind == .argumentRefused)
        #expect("\(try #require(refusal))".contains("payload.aps holds what JSON does not write"))
        #expect(!sut.backend.performed.contains { operation in "\(operation)".hasPrefix("PushNotificationOperator") })
    }
    
    @Test("what the device refuses of an argument is the scenario's refusal", arguments: [
        ("open_url", "{ url: \"\" }"),
        ("push_notification", "{ bundle_id: com.example.app, payload: {} }")
    ])
    func aRefusedArgument(_ procedure: String, _ arguments: String) async throws {
        // Given
        let sut = try DeviceStage()
        
        // When
        let refusal = await #expect(throws: StepFailure.self) {
            _ = try await sut.run(verbCall(procedure, arguments))
        }
        
        // Then
        #expect(try #require(refusal).kind == .argumentRefused)
    }
    
    // MARK: - Private
}

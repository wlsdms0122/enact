//
//  EnvironmentActionTests.swift
//  EnactWarpTests
//
//  Created by JSilver on 10/31/26.
//

import Foundation
import Testing
import Warp
@testable import EnactWarp

@Suite("Environment verbs set what the device shows and allows")
struct EnvironmentActionTests {
    // MARK: - Property
    // MARK: - Initializer
    // MARK: - Test
    @Test("each environment verb hands the device the operation its arguments say", arguments: [
        ("set_appearance", "{ value: { case: dark } }", "SetAppearanceOperator(appearance: Digit.Appearance.dark)"),
        ("set_content_size", "{ value: { case: extraLarge } }", "SetContentSizeOperator(size: Digit.ContentSize.extraLarge)"),
        ("set_contrast", "{ value: { case: increased } }", "SetContrastOperator(contrast: Digit.Contrast.increased)"),
        ("set_orientation", "{ value: { case: landscapeLeft } }", "SetOrientationOperator(orientation: Digit.Orientation.landscapeLeft)"),
        (
            "set_privacy",
            "{ action: { case: grant }, service: [ { case: photos } ], bundle_id: com.example.app }",
            "SetPrivacyOperator(decision: Digit.SetPrivacyOperator.Decision.grant, bundleID: Optional(\"com.example.app\"), services: Set([Digit.PrivacyService.photos]))"
        ),
        (
            "reset_privacy",
            "{ service: [ { case: locationAlways } ] }",
            "SetPrivacyOperator(decision: Digit.SetPrivacyOperator.Decision.reset, bundleID: nil, services: Set([Digit.PrivacyService.locationAlways]))"
        ),
        (
            "set_location",
            "{ lat: 37.5, lon: 127 }",
            "SetLocationOperator(update: Digit.LocationUpdate.fixed(Digit.Coordinate(latitude: 37.5, longitude: 127.0)))"
        ),
        ("set_location_route", "{ route: City Run }", "SetLocationOperator(update: Digit.LocationUpdate.scenario(\"City Run\"))"),
        (
            "set_location_waypoints",
            "{ waypoints: [ { struct: { lat: 37.5, lon: 127 } }, { struct: { lat: 37.6, lon: 127.1 } } ], speed: 30 }",
            "SetLocationOperator(update: Digit.LocationUpdate.waypoints([Digit.Coordinate(latitude: 37.5, longitude: 127.0), Digit.Coordinate(latitude: 37.6, longitude: 127.1)], speed: Optional(30.0)))"
        ),
        (
            "set_status_bar",
            "{ time: \"9:41\", data_network: { case: fiveGPlus }, wifi_bars: 3, battery_state: { case: charging }, battery_level: 100 }",
            "SetStatusBarOperator(time: Optional(\"9:41\"), dataNetwork: Optional(Digit.DataNetwork.fiveGPlus), wifiMode: nil, wifiBars: Optional(3), cellularMode: nil, cellularBars: nil, operatorName: nil, batteryState: Optional(Digit.BatteryState.charging), batteryLevel: Optional(100))"
        ),
        ("add_media", "{ paths: [/tmp/a.png] }", "AddMediaOperator(paths: [\"/tmp/a.png\"])"),
        ("add_certificate", "{ path: /tmp/a.pem }", "AddCertificateOperator(path: \"/tmp/a.pem\", root: false)"),
        ("add_root_certificate", "{ path: /tmp/proxy.pem }", "AddCertificateOperator(path: \"/tmp/proxy.pem\", root: true)")
    ])
    func eachVerbHandsTheDeviceItsOperation(_ procedure: String, _ arguments: String, _ expected: String) async throws {
        // Given
        let sut = try DeviceStage()
        
        // When
        _ = try await sut.run(verbCall(procedure, arguments))
        
        // Then
        #expect(sut.backend.performed.map(String.init(describing:)) == [expected])
    }
    
    @Test("clearing takes no arguments", arguments: [
        ("clear_location", "SetLocationOperator(update: Digit.LocationUpdate.clear)"),
        ("reset_keychain", "ResetKeychainOperator()"),
        (
            "clear_status_bar",
            "SetStatusBarOperator(time: nil, dataNetwork: nil, wifiMode: nil, wifiBars: nil, cellularMode: nil, cellularBars: nil, operatorName: nil, batteryState: nil, batteryLevel: nil)"
        )
    ])
    func clearingTakesNoArguments(_ procedure: String, _ expected: String) async throws {
        // Given
        let sut = try DeviceStage()
        
        // When
        _ = try await sut.run(verbCall(procedure))
        
        // Then
        #expect(sut.backend.performed.map(String.init(describing:)) == [expected])
    }
    
    @Test("folding and unfolding take no arguments", arguments: [
        ("fold", "SetHingeOperator(hinge: Digit.Hinge.folded)"),
        ("unfold", "SetHingeOperator(hinge: Digit.Hinge.unfolded)")
    ])
    func foldingTakesNoArguments(_ procedure: String, _ expected: String) async throws {
        // Given
        let sut = try DeviceStage()
        
        // When
        _ = try await sut.run(verbCall(procedure))
        
        // Then
        #expect(sut.backend.performed.map(String.init(describing:)) == [expected])
    }
    
    @Test("connecting and disconnecting the hardware keyboard take no arguments", arguments: [
        ("connect_hardware_keyboard", "SetHardwareKeyboardOperator(keyboard: Digit.HardwareKeyboard.connected)"),
        ("disconnect_hardware_keyboard", "SetHardwareKeyboardOperator(keyboard: Digit.HardwareKeyboard.disconnected)")
    ])
    func hardwareKeyboardTakesNoArguments(_ procedure: String, _ expected: String) async throws {
        // Given
        let sut = try DeviceStage()
        
        // When
        _ = try await sut.run(verbCall(procedure))
        
        // Then
        #expect(sut.backend.performed.map(String.init(describing:)) == [expected])
    }
    
    @Test("turning application accessibility on and off take no arguments", arguments: [
        ("enable_app_accessibility", "SetAppAccessibilityOperator(accessibility: Digit.AppAccessibility.enabled)"),
        ("disable_app_accessibility", "SetAppAccessibilityOperator(accessibility: Digit.AppAccessibility.disabled)")
    ])
    func appAccessibilityTakesNoArguments(_ procedure: String, _ expected: String) async throws {
        // Given
        let sut = try DeviceStage()
        
        // When
        _ = try await sut.run(verbCall(procedure))
        
        // Then
        #expect(sut.backend.performed.map(String.init(describing:)) == [expected])
    }
    
    @Test("application accessibility is read as whether it is on")
    func appAccessibilityIsReadAsABool() async throws {
        // Given
        let sut = try DeviceStage()
        
        // When
        let result = try await sut.run(verbCall("is_app_accessibility_enabled", returns: "Bool"))
        
        // Then
        #expect(result == .bool(true))
        #expect(sut.backend.performed.map(String.init(describing:)) == ["AppAccessibilityOperator()"])
    }
    
    @Test("a bar past its count is refused")
    func aRefusedArgument() async throws {
        // Given
        let sut = try DeviceStage()
        
        // When
        let refusal = await #expect(throws: StepFailure.self) {
            _ = try await sut.run(verbCall("set_status_bar", "{ wifi_bars: 9 }"))
        }
        
        // Then
        #expect(try #require(refusal).kind == .argumentRefused)
        #expect(sut.backend.performed.isEmpty)
    }
    
    // MARK: - Private
}

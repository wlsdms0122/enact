//
//  SimulatorEnvironment.swift
//  Digit
//
//  Created by JSilver on 8/16/26.
//

import CoreSimulator
import FBSimulatorControl
import FBSimulatorServices
import Foundation

struct SimulatorEnvironment {
    // MARK: - Property
    var implementations: [Implementation] {
        [
            .perform(setAppearance),
            .perform(setContentSize),
            .perform(setContrast),
            .perform(setPrivacy),
            .perform(setLocation),
            .perform(setStatusBar),
            .perform(setOrientation),
            .perform(setHinge),
            .perform(setHardwareKeyboard),
            .perform(appAccessibility),
            .perform(setAppAccessibility),
            .perform(addMedia),
            .perform(addCertificate),
            .perform(resetKeychain)
        ]
    }
    
    // A screen switched by the hinge comes up a few seconds after the angle
    // is reported.
    private static let settleTimeout: Duration = .seconds(10)
    private static let settlePollInterval: Duration = .milliseconds(200)
    
    private let simulator: Simulator
    private let simctl = Simctl()
    
    // MARK: - Initializer
    init(simulator: Simulator) {
        self.simulator = simulator
    }
    
    // MARK: - Public
    // MARK: - Private
    private func setAppearance(_ operation: SetAppearanceOperator) async throws {
        try await simulator.preferences.apply(
            .appearance(SimulatorAppearance(operation.appearance))
        )
    }
    
    private func setContentSize(_ operation: SetContentSizeOperator) async throws {
        try await simulator.preferences.apply(
            .contentSize(SimulatorContentSizeCategory(operation.size))
        )
    }
    
    private func setContrast(_ operation: SetContrastOperator) async throws {
        try simulator.device.setIncreaseContrastEnabled(operation.contrast == .increased)
    }
    
    private func setPrivacy(_ operation: SetPrivacyOperator) async throws {
        for service in operation.services.map(\.rawValue).sorted() {
            var arguments = [
                "privacy", simulator.udid, operation.decision.rawValue, service
            ]
            
            if let bundleID = operation.bundleID { arguments.append(bundleID) }
            
            try simctl.run(arguments)
        }
    }
    
    private func setLocation(_ operation: SetLocationOperator) async throws {
        switch operation.update {
        case let .fixed(coordinate):
            try await simulator.location.set(
                longitude: coordinate.longitude,
                latitude: coordinate.latitude
            )
        
        case let .scenario(name):
            let scenarios = simulator.device.availableLocationScenarios() as? [[String: String]]
            let available = (scenarios ?? []).compactMap { $0["name"] }
            
            guard let match = available.first(where: { slug($0) == slug(name) }) else {
                throw DigitError.noSuchOption(
                    field: "location scenario",
                    value: name,
                    available: available.map(slug).sorted()
                )
            }
            
            try simulator.device.setLocationScenario(match)
        
        case let .waypoints(waypoints, speed):
            let points = waypoints.map { waypoint in "\(waypoint.latitude),\(waypoint.longitude)" }
            let pace = speed.map { speed in ["--speed=\(speed)"] } ?? []
            
            try simctl.run(["location", simulator.udid, "start"] + pace + points)
        
        case .clear:
            try simulator.device.clearSimulatedLocation()
        }
    }
    
    private func setStatusBar(_ operation: SetStatusBarOperator) async throws {
        guard !operation.isEmpty else {
            try await simulator.statusBar.set(nil)
            
            return
        }
        
        var override = try await simulator.statusBar.current()
        
        override.apply(operation)
        
        try await simulator.statusBar.set(override)
    }
    
    // Turning the device is asked of the guest bridge.
    private func setOrientation(_ operation: SetOrientationOperator) async throws {
        try SimulatorFrameworkBridge.install()
        
        _ = try await simulator.orientation.set(
            SimulatorDeviceOrientation(operation.orientation),
            confirmingWithin: Self.settleTimeout
        )
    }
    
    private func setHinge(_ operation: SetHingeOperator) async throws {
        let capabilities = try await simulator.capabilities()
        
        guard capabilities.hingeAngle else {
            throw CapabilityError(operation: SetHingeOperator.operation, target: DeviceInfo(simulator))
        }
        
        let angle = try SimulatorHingeAngle(operation.hinge)
        
        guard try await simulator.hinge.current() != angle else { return }
        
        let before = try await simulator.displays.configuration().activeGeometry()
        
        _ = try await simulator.hinge.set(angle, confirmingWithin: Self.settleTimeout)
        
        if capabilities.multipleDisplays {
            try await waitForScreen(leaving: before)
        }
    }
    
    private func setHardwareKeyboard(_ operation: SetHardwareKeyboardOperator) async throws {
        try simulator.device.setHardwareKeyboardEnabled(operation.keyboard == .connected, keyboardType: 0)
    }
    
    private func appAccessibility(_: AppAccessibilityOperator) throws -> AppAccessibility {
        try ApplePrivate(simulator: simulator).isApplicationAccessibilityEnabled() ? .enabled : .disabled
    }
    
    private func setAppAccessibility(_ operation: SetAppAccessibilityOperator) async throws {
        try await ApplePrivate(simulator: simulator).setApplicationAccessibility(enabled: operation.accessibility == .enabled)
    }
    
    private func waitForScreen(leaving before: SimulatorDisplayGeometry) async throws {
        let deadline = ContinuousClock.now + Self.settleTimeout
        
        while try await isShowing(before, settlingBy: deadline) {
            guard ContinuousClock.now < deadline else {
                throw DigitError.commandFailed(
                    command: Operation.setHinge.rawValue,
                    message: "the screen did not follow the hinge within \(Self.settleTimeout)"
                )
            }
            
            try await Task.sleep(for: Self.settlePollInterval)
        }
    }
    
    // A transition still running when the time left is spent has not left the screen yet.
    private func isShowing(
        _ geometry: SimulatorDisplayGeometry,
        settlingBy deadline: ContinuousClock.Instant
    ) async throws -> Bool {
        let left = max(deadline - ContinuousClock.now, .zero)
        
        do {
            return try await simulator.displays.configuration(settledWithin: left).activeGeometry() == geometry
        } catch SimulatorDisplayError.transitioning {
            return true
        }
    }
    
    private func addMedia(_ operation: AddMediaOperator) async throws {
        try simulator.media.upload(operation.paths.map(URL.init(fileURLWithPath:)))
    }
    
    private func addCertificate(_ operation: AddCertificateOperator) async throws {
        try simctl.run(["keychain", simulator.udid, operation.root ? "add-root-cert" : "add-cert", operation.path])
    }
    
    private func resetKeychain(_ operation: ResetKeychainOperator) async throws {
        try await simulator.keychain.clear()
    }
    
    private func slug(_ name: String) -> String {
        name.lowercased()
            .split(whereSeparator: { $0 == " " || $0 == "_" })
            .joined(separator: "-")
    }
}

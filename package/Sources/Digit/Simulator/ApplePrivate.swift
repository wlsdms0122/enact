//
//  ApplePrivate.swift
//  Digit
//
//  Created by JSilver on 11/2/26.
//

import CoreSimulator
import FBSimulatorControl
import FBSimulatorServices
import Foundation

// The simulator runtime's unpublished names that Digit spells itself: preference keys,
// Darwin notifications and device features. None of them is a contract, so a runtime
// that renames one or changes what it does is answered here, branching on the runtime
// version where it must.
struct ApplePrivate {
    // MARK: - Property
    private static let accessibilityDomain = "com.apple.Accessibility"
    private static let applicationAccessibilityKey = "ApplicationAccessibilityEnabled"
    
    var biometric: Biometric? {
        if simulator.device.supportsFeature("com.apple.pearl-id") { return .face }
        if simulator.device.supportsFeature("com.apple.touch-id") { return .touch }
        
        return nil
    }
    
    private let simulator: Simulator
    
    // MARK: - Initializer
    init(simulator: Simulator) {
        self.simulator = simulator
    }
    
    // MARK: - Public
    // Read from the device's preferences file, which `defaults` writes through as it
    // sets the value. A device that never had it set has it off.
    func isApplicationAccessibilityEnabled() throws -> Bool {
        let file = URL(fileURLWithPath: simulator.device.dataPath())
            .appending(path: "Library/Preferences/\(Self.accessibilityDomain).plist")
        
        guard FileManager.default.fileExists(atPath: file.path) else { return false }
        
        let preferences = try PropertyListSerialization.propertyList(from: try Data(contentsOf: file), format: nil)
        
        return ((preferences as? [String: Any])?[Self.applicationAccessibilityKey] as? Bool) ?? false
    }
    
    // Running applications re-read the setting on the notification, so one launched with
    // it off starts its server in place. Turning it off again leaves started servers
    // running.
    func setApplicationAccessibility(enabled: Bool) async throws {
        try await simulator.preferences.apply(
            .preference(
                name: Self.applicationAccessibilityKey,
                value: enabled ? "true" : "false",
                type: "bool",
                domain: Self.accessibilityDomain
            )
        )
        
        try simulator.device.postDarwinNotification("com.apple.accessibility.cache.ax")
    }
    
    func respond(to biometric: Biometric, with outcome: BiometricOutcome) throws {
        let sensor =
            switch biometric {
            case .face: "pearl"
            case .touch: "fingerTouch"
            }
        let answer =
            switch outcome {
            case .match: "match"
            case .noMatch: "nomatch"
            }
        
        try simulator.device.postDarwinNotification("com.apple.BiometricKit_Sim.\(sensor).\(answer)")
    }
    
    // MARK: - Private
}

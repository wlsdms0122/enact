//
//  SetPrivacy.swift
//  DigitCLI
//
//  Created by JSilver on 8/16/26.
//

import ArgumentParser
import Digit
import Foundation

package struct SetPrivacy: DeviceCommand {
    // MARK: - Property
    package static let configuration = CommandConfiguration(
        commandName: Operation.setPrivacy.rawValue,
        abstract: "Grant or revoke an app's permissions."
    )
    
    @OptionGroup package var target: DeviceOption
    @Option(name: .customLong("bundle-id"), help: "the app; only reset may leave it out")
    package var bundleID: String?
    @Argument(help: "grant, revoke or reset") package var decision: SetPrivacyOperator.Decision
    @Option(name: .customLong("service"), help: "permission to change (repeatable)")
    package var services: [PrivacyService]
    
    // MARK: - Initializer
    package init() {}
    
    // MARK: - Public
    package func perform(on device: Device) async throws -> Empty {
        let change = try SetPrivacyOperator(
            decision: decision,
            bundleID: bundleID,
            services: Set(services)
        )
        
        try await device.run(change)
        
        return Empty()
    }
    
    // MARK: - Private
}

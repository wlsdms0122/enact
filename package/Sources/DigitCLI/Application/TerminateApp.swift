//
//  TerminateApp.swift
//  DigitCLI
//
//  Created by JSilver on 8/16/26.
//

import ArgumentParser
import Digit
import Foundation

package struct TerminateApp: DeviceCommand {
    // MARK: - Property
    package static let configuration = CommandConfiguration(
        commandName: Operation.terminateApp.rawValue,
        abstract: "Stop a running app."
    )
    
    @OptionGroup package var target: DeviceOption
    @Option(name: .customLong("bundle-id"), help: "bundle identifier") package var bundleID: String
    
    // MARK: - Initializer
    package init() {}
    
    // MARK: - Public
    package func perform(on device: Device) async throws -> Empty {
        try await device.run(TerminateAppOperator(bundleID: bundleID))
        
        return Empty()
    }
    
    // MARK: - Private
}

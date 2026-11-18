//
//  InstallApp.swift
//  DigitCLI
//
//  Created by JSilver on 8/16/26.
//

import ArgumentParser
import Digit
import Foundation

package struct InstallApp: DeviceCommand {
    // MARK: - Property
    package static let configuration = CommandConfiguration(
        commandName: Operation.installApp.rawValue,
        abstract: "Install an app bundle."
    )
    
    @OptionGroup package var target: DeviceOption
    @Option(help: "path to the .app bundle") package var path: String
    
    // MARK: - Initializer
    package init() {}
    
    // MARK: - Public
    package func perform(on device: Device) async throws -> Empty {
        try await device.run(InstallAppOperator(path: path))
        
        return Empty()
    }
    
    // MARK: - Private
}

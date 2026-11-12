//
//  OpenURL.swift
//  DigitCLI
//
//  Created by JSilver on 8/16/26.
//

import ArgumentParser
import Digit
import Foundation

package struct OpenURL: DeviceCommand {
    // MARK: - Property
    package static let configuration = CommandConfiguration(
        commandName: Operation.openURL.rawValue,
        abstract: "Open a URL or deep link."
    )
    
    @OptionGroup package var target: DeviceOption
    @Argument(help: "url to open") package var url: String
    
    // MARK: - Initializer
    package init() {}
    
    // MARK: - Public
    package func perform(on device: Device) async throws -> Empty {
        guard let parsed = URL(string: url) else { throw ValidationError("not a url: \(url)") }
        
        try await device.run(OpenURLOperator(parsed))
        
        return Empty()
    }
    
    // MARK: - Private
}

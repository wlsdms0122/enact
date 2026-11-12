//
//  SetAppearance.swift
//  DigitCLI
//
//  Created by JSilver on 8/16/26.
//

import ArgumentParser
import Digit
import Foundation

package struct SetAppearance: DeviceCommand {
    // MARK: - Property
    package static let configuration = CommandConfiguration(
        commandName: Operation.setAppearance.rawValue,
        abstract: "Switch light or dark mode."
    )
    
    @OptionGroup package var target: DeviceOption
    @Argument(help: "light or dark") package var appearance: Appearance
    
    // MARK: - Initializer
    package init() {}
    
    // MARK: - Public
    package func perform(on device: Device) async throws -> Empty {
        try await device.run(SetAppearanceOperator(appearance))
        
        return Empty()
    }
    
    // MARK: - Private
}

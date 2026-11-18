//
//  SetContrast.swift
//  DigitCLI
//
//  Created by JSilver on 8/16/26.
//

import ArgumentParser
import Digit
import Foundation

package struct SetContrast: DeviceCommand {
    // MARK: - Property
    package static let configuration = CommandConfiguration(
        commandName: Operation.setContrast.rawValue,
        abstract: "Raise or restore interface contrast."
    )
    
    @OptionGroup package var target: DeviceOption
    @Argument(help: "standard or increased") package var contrast: Contrast
    
    // MARK: - Initializer
    package init() {}
    
    // MARK: - Public
    package func perform(on device: Device) async throws -> Empty {
        try await device.run(SetContrastOperator(contrast))
        
        return Empty()
    }
    
    // MARK: - Private
}

//
//  SetOrientation.swift
//  DigitCLI
//
//  Created by JSilver on 11/5/26.
//

import ArgumentParser
import Digit
import Foundation

package struct SetOrientation: DeviceCommand {
    // MARK: - Property
    package static let configuration = CommandConfiguration(
        commandName: Operation.setOrientation.rawValue,
        abstract: "Turn the device so the interface follows."
    )
    
    @OptionGroup package var target: DeviceOption
    @Argument(help: "portrait, portrait-upside-down, landscape-left or landscape-right") package var orientation: Orientation
    
    // MARK: - Initializer
    package init() {}
    
    // MARK: - Public
    package func perform(on device: Device) async throws -> Empty {
        try await device.run(SetOrientationOperator(orientation))
        
        return Empty()
    }
    
    // MARK: - Private
}

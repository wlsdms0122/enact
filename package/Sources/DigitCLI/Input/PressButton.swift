//
//  PressButton.swift
//  DigitCLI
//
//  Created by JSilver on 8/16/26.
//

import ArgumentParser
import Digit
import Foundation

package struct PressButton: DeviceCommand {
    // MARK: - Property
    package static let configuration = CommandConfiguration(
        commandName: Operation.pressButton.rawValue,
        abstract: "Press a hardware button."
    )
    
    @OptionGroup package var target: DeviceOption
    @Argument(help: "home, lock, side, siri or apple-pay") package var button: Button
    
    // MARK: - Initializer
    package init() {}
    
    // MARK: - Public
    package func perform(on device: Device) async throws -> Empty {
        try await device.run(PressButtonOperator(button))
        
        return Empty()
    }
    
    // MARK: - Private
}

//
//  SetHardwareKeyboard.swift
//  DigitCLI
//
//  Created by JSilver on 11/9/26.
//

import ArgumentParser
import Digit
import Foundation

package struct SetHardwareKeyboard: DeviceCommand {
    // MARK: - Property
    package static let configuration = CommandConfiguration(
        commandName: Operation.setHardwareKeyboard.rawValue,
        abstract: "Connect or disconnect the hardware keyboard.",
        discussion: "The software keyboard shows only while it is disconnected."
    )
    
    @OptionGroup package var target: DeviceOption
    @Argument(help: "connected or disconnected") package var keyboard: HardwareKeyboard
    
    // MARK: - Initializer
    package init() {}
    
    // MARK: - Public
    package func perform(on device: Device) async throws -> Empty {
        try await device.run(SetHardwareKeyboardOperator(keyboard))
        
        return Empty()
    }
    
    // MARK: - Private
}

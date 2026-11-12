//
//  RespondBiometric.swift
//  DigitCLI
//
//  Created by JSilver on 8/16/26.
//

import ArgumentParser
import Digit
import Foundation

package struct RespondBiometric: DeviceCommand {
    // MARK: - Property
    package static let configuration = CommandConfiguration(
        commandName: Operation.respondBiometric.rawValue,
        abstract: "Answer the Face ID or Touch ID prompt on screen.",
        discussion: """
            Which of the two the device has is read off the hardware, so it is \
            not asked for. A device with neither does not support this.
            """
    )
    
    @OptionGroup package var target: DeviceOption
    @Argument(help: "match or no-match") package var outcome: BiometricOutcome = .match
    
    // MARK: - Initializer
    package init() {}
    
    // MARK: - Public
    package func perform(on device: Device) async throws -> Empty {
        try await device.run(RespondBiometricOperator(outcome))
        
        return Empty()
    }
    
    // MARK: - Private
}

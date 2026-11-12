//
//  ResetKeychain.swift
//  DigitCLI
//
//  Created by JSilver on 11/5/26.
//

import ArgumentParser
import Digit
import Foundation

package struct ResetKeychain: DeviceCommand {
    // MARK: - Property
    package static let configuration = CommandConfiguration(
        commandName: Operation.resetKeychain.rawValue,
        abstract: "Empty the keychain.",
        discussion: "A certificate trusted as a root stays trusted until the device is erased."
    )
    
    @OptionGroup package var target: DeviceOption
    
    // MARK: - Initializer
    package init() {}
    
    // MARK: - Public
    package func perform(on device: Device) async throws -> Empty {
        try await device.run(ResetKeychainOperator())
        
        return Empty()
    }
    
    // MARK: - Private
}

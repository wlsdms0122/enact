//
//  PressKey.swift
//  DigitCLI
//
//  Created by JSilver on 8/16/26.
//

import ArgumentParser
import Digit
import Foundation

package struct PressKey: DeviceCommand {
    // MARK: - Property
    package static let configuration = CommandConfiguration(
        commandName: Operation.pressKey.rawValue,
        abstract: "Press a key, optionally with modifiers held.",
        discussion: """
            Keys are named (return, escape, tab, up …) or a single character: \
            --modifier command --key a
            """
    )
    
    @OptionGroup package var target: DeviceOption
    @Option(help: "key to press") package var key: String
    @Option(name: .customLong("modifier"), help: "shift, control, option or command (repeatable)")
    package var modifiers: [Modifier] = []
    
    // MARK: - Initializer
    package init() {}
    
    // MARK: - Public
    package func perform(on device: Device) async throws -> Empty {
        try await device.run(`operator`())
        
        return Empty()
    }
    
    // MARK: - Private
    private func `operator`() throws -> PressKeyOperator {
        guard let press = KeyboardLayout().press(named: key) else {
            throw ValidationError("unknown key: \(key)")
        }
        
        return PressKeyOperator(press: press, modifiers: modifiers)
    }
}

//
//  SetPasteboard.swift
//  DigitCLI
//
//  Created by JSilver on 8/16/26.
//

import ArgumentParser
import Digit
import Foundation

package struct SetPasteboard: DeviceCommand {
    // MARK: - Property
    package static let configuration = CommandConfiguration(
        commandName: Operation.setPasteboard.rawValue,
        abstract: "Put text on the device's clipboard.",
        discussion: """
            The way anything a US keyboard has no key for (Hangul, newlines) \
            reaches the device. Paste it with a key press: \
            press-key --key v --modifier command. Pass - to read from stdin. \
            It fails where the pasteboard does not read back what was written.
            """
    )
    
    @OptionGroup package var target: DeviceOption
    @Argument(help: "text to put on the clipboard, or - to read it from stdin") package var text: String
    
    // MARK: - Initializer
    package init() {}
    
    // MARK: - Public
    package func reading(_ input: StandardInput) throws -> Self {
        guard text == "-" else { return self }
        
        var command = self
        command.text = try input.text(as: "clipboard text")
        
        return command
    }
    
    package func perform(on device: Device) async throws -> Empty {
        try await device.run(SetPasteboardOperator(text))
        
        return Empty()
    }
    
    // MARK: - Private
}

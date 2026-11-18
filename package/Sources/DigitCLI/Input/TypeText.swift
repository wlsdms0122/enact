//
//  TypeText.swift
//  DigitCLI
//
//  Created by JSilver on 8/16/26.
//

import ArgumentParser
import Digit
import Foundation

package struct TypeText: DeviceCommand {
    // MARK: - Property
    package static let configuration = CommandConfiguration(
        commandName: Operation.typeText.rawValue,
        abstract: "Type text by tapping the software keyboard's keys.",
        discussion: """
            The text goes to whatever the software keyboard on the screen types \
            into, so tap the field first. Each character is typed by tapping the \
            key labeled with it, in any keyboard the device has, finding the layer \
            and keyboard that has it by tapping shift, the number key and Next \
            keyboard. Korean is spelled with the two-set keys; a return and a tab \
            are hardware key presses. A connected hardware keyboard keeps the \
            software keyboard away; disconnect it with set-hardware-keyboard \
            disconnected. With no software keyboard on the screen the call fails. \
            A character no keyboard of the device has is refused before anything \
            is typed, and the keyboard is left on the one it was found on. A tap \
            that leaves every field as it was fails the call, except where the \
            screen shows no field the first tap changes, as a web page's. For text \
            typed fast, or that no key types, put it on the clipboard with \
            set-pasteboard and paste it: press-key --key v --modifier command.
            """
    )
    
    @OptionGroup package var target: DeviceOption
    @Argument(help: "text to type") package var text: String
    
    // MARK: - Initializer
    package init() {}
    
    // MARK: - Public
    package func perform(on device: Device) async throws -> Empty {
        try await device.run(`operator`())
        
        return Empty()
    }
    
    // MARK: - Private
    private func `operator`() throws -> TypeTextOperator {
        try TypeTextOperator(text)
    }
}

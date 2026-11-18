//
//  SetAppAccessibility.swift
//  DigitCLI
//
//  Created by JSilver on 11/11/26.
//

import ArgumentParser
import Digit
import Foundation

package struct SetAppAccessibility: DeviceCommand {
    // MARK: - Property
    package static let configuration = CommandConfiguration(
        commandName: Operation.setAppAccessibility.rawValue,
        abstract: "Turn application accessibility on or off.",
        discussion: """
            An app serves its accessibility only while it is on, and every read \
            of the screen turns it on again where it is off. Turning it off \
            leaves the apps already serving it serving.
            """
    )
    
    @OptionGroup package var target: DeviceOption
    @Argument(help: "enabled or disabled") package var accessibility: AppAccessibility
    
    // MARK: - Initializer
    package init() {}
    
    // MARK: - Public
    package func perform(on device: Device) async throws -> Empty {
        try await device.run(SetAppAccessibilityOperator(accessibility))
        
        return Empty()
    }
    
    // MARK: - Private
}

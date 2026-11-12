//
//  ReadAppAccessibility.swift
//  DigitCLI
//
//  Created by JSilver on 11/11/26.
//

import ArgumentParser
import Digit
import Foundation

struct ReadAppAccessibility: DeviceCommand {
    // MARK: - Property
    static let configuration = CommandConfiguration(
        commandName: Operation.appAccessibility.rawValue,
        abstract: "Print whether application accessibility is enabled or disabled."
    )
    
    @OptionGroup var target: DeviceOption
    
    // MARK: - Initializer
    // MARK: - Public
    func perform(on device: Device) async throws -> AppAccessibility {
        try await device.run(AppAccessibilityOperator())
    }
    
    func show(_ answer: AppAccessibility) { print(answer.rawValue) }
    
    // MARK: - Private
}

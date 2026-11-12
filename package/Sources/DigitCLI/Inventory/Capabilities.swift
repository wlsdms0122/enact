//
//  Capabilities.swift
//  DigitCLI
//
//  Created by JSilver on 8/16/26.
//

import ArgumentParser
import Digit
import Foundation

struct Capabilities: DeviceCommand {
    // MARK: - Property
    static let configuration = CommandConfiguration(
        commandName: "capabilities",
        abstract: "Operations this device supports.",
        discussion: """
            Comparing a scenario against this before running it turns a failure \
            forty steps in into an immediate refusal.
            """
    )
    
    @OptionGroup var target: DeviceOption
    @OptionGroup var output: OutputOption
    
    // MARK: - Initializer
    // MARK: - Public
    func perform(on device: Device) async throws -> [String] {
        device.capabilities.map(\.rawValue).sorted()
    }
    
    func show(_ answer: [String]) throws {
        try output.emit(answer) { answer.joined(separator: "\n") }
    }
    
    // MARK: - Private
}

//
//  ReadPasteboard.swift
//  DigitCLI
//
//  Created by JSilver on 8/16/26.
//

import ArgumentParser
import Digit
import Foundation

struct ReadPasteboard: DeviceCommand {
    // MARK: - Property
    static let configuration = CommandConfiguration(
        commandName: Operation.readPasteboard.rawValue,
        abstract: "Print what is on the device's clipboard."
    )
    
    @OptionGroup var target: DeviceOption
    
    // MARK: - Initializer
    // MARK: - Public
    func perform(on device: Device) async throws -> String { try await device.run(ReadPasteboardOperator()) }
    
    func show(_ answer: String) { print(answer) }
    
    // MARK: - Private
}

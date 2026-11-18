//
//  Erase.swift
//  DigitCLI
//
//  Created by JSilver on 8/16/26.
//

import ArgumentParser
import Digit
import Foundation

struct Erase: AsyncParsableCommand {
    // MARK: - Property
    static let configuration = CommandConfiguration(
        commandName: Operation.erase.rawValue,
        abstract: "Erase the device back to a clean state.",
        discussion: "A booted device is shut down first, then erased."
    )
    
    @OptionGroup var target: DeviceOption
    
    // MARK: - Initializer
    // MARK: - Public
    func run() async throws { try await target.device().run(EraseOperator()) }
    
    // MARK: - Private
}

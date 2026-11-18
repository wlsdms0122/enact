//
//  Shutdown.swift
//  DigitCLI
//
//  Created by JSilver on 8/16/26.
//

import ArgumentParser
import Digit
import Foundation

struct Shutdown: AsyncParsableCommand {
    // MARK: - Property
    static let configuration = CommandConfiguration(
        commandName: Operation.shutdown.rawValue,
        abstract: "Shut the device down."
    )
    
    @OptionGroup var target: DeviceOption
    
    // MARK: - Initializer
    // MARK: - Public
    func run() async throws { try await target.device().run(ShutdownOperator()) }
    
    // MARK: - Private
}

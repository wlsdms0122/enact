//
//  Boot.swift
//  DigitCLI
//
//  Created by JSilver on 8/16/26.
//

import ArgumentParser
import Digit
import Foundation

struct Boot: AsyncParsableCommand {
    // MARK: - Property
    static let configuration = CommandConfiguration(
        commandName: Operation.boot.rawValue,
        abstract: "Boot the device, and wait until its screen can be read."
    )
    
    @OptionGroup var target: DeviceOption
    
    // MARK: - Initializer
    // MARK: - Public
    func run() async throws { try await target.device().run(BootOperator()) }
    
    // MARK: - Private
}

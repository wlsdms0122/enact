//
//  Reboot.swift
//  DigitCLI
//
//  Created by JSilver on 11/5/26.
//

import ArgumentParser
import Digit
import Foundation

struct Reboot: AsyncParsableCommand {
    // MARK: - Property
    static let configuration = CommandConfiguration(
        commandName: Operation.reboot.rawValue,
        abstract: "Reboot the device, and wait until its screen can be read."
    )
    
    @OptionGroup var target: DeviceOption
    
    // MARK: - Initializer
    // MARK: - Public
    func run() async throws { try await target.device().run(RebootOperator()) }
    
    // MARK: - Private
}

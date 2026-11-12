//
//  Lookup.swift
//  DigitCLI
//
//  Created by JSilver on 8/16/26.
//

import ArgumentParser
import Digit
import Foundation

struct Lookup: AsyncParsableCommand {
    // MARK: - Property
    static let configuration = CommandConfiguration(
        commandName: "resolve",
        abstract: "Print the concrete udid an argument names.",
        discussion: """
            `--udid booted` is accepted by every command that addresses a \
            device, so this is for callers that need the udid itself: to key \
            a lock file by it, or to say in an answer which device was meant.
            """
    )
    
    @OptionGroup var target: DeviceOption
    
    // MARK: - Initializer
    // MARK: - Public
    func run() async throws { print(try DeviceSet().resolve(udid: target.udid)) }
    
    // MARK: - Private
}

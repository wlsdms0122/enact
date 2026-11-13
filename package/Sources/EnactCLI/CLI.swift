//
//  CLI.swift
//  EnactCLI
//
//  Created by JSilver on 8/16/26.
//

import ArgumentParser
import DigitCLI
import Foundation

@main
struct EnactCLI: AsyncParsableCommand {
    // MARK: - Property
    static let configuration = CommandConfiguration(
        commandName: "enact",
        abstract: "Carry out scenarios on a device, and the device operations they are made of.",
        subcommands: [Run.self, Eval.self, Draft.self, Check.self, Graph.self, DeviceGroup.self]
    )
    
    // MARK: - Initializer
    // MARK: - Public
    // MARK: - Private
}

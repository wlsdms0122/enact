//
//  Clone.swift
//  DigitCLI
//
//  Created by JSilver on 11/5/26.
//

import ArgumentParser
import Digit
import Foundation

struct Clone: AsyncParsableCommand {
    // MARK: - Property
    static let configuration = CommandConfiguration(
        commandName: "clone",
        abstract: "Copy a device, with what is installed on it, and print the copy.",
        discussion: "The device has to be shut down."
    )
    
    @Option(name: .customLong("udid"), help: "udid of the device to copy") var udid: String
    @Option(help: "what the copy is called") var name: String
    @OptionGroup var output: OutputOption
    
    // MARK: - Initializer
    // MARK: - Public
    func run() async throws {
        let cloned = try DeviceSet().clone(udid: udid, named: name)
        
        try output.emit(cloned) { TerminalTable().render([cloned.terminalRow]) }
    }
    
    // MARK: - Private
}

//
//  Create.swift
//  DigitCLI
//
//  Created by JSilver on 11/5/26.
//

import ArgumentParser
import Digit
import Foundation

struct Create: AsyncParsableCommand {
    // MARK: - Property
    static let configuration = CommandConfiguration(
        commandName: "create",
        abstract: "Create a device and print it.",
        discussion: """
            The type and the runtime are named as `xcrun simctl list devicetypes` \
            and `xcrun simctl list runtimes` name them. With no runtime, the \
            newest the type runs.
            """
    )
    
    @Option(help: "what the device is called") var name: String
    @Option(name: .customLong("device-type"), help: "e.g. \"iPhone 17 Pro\"") var deviceType: String
    @Option(help: "e.g. iOS27.2") var runtime: String?
    @OptionGroup var output: OutputOption
    
    // MARK: - Initializer
    // MARK: - Public
    func run() async throws {
        let created = try DeviceSet().create(named: name, deviceType: deviceType, runtime: runtime)
        
        try output.emit(created) { TerminalTable().render([created.terminalRow]) }
    }
    
    // MARK: - Private
}

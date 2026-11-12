//
//  ListTargets.swift
//  DigitCLI
//
//  Created by JSilver on 8/16/26.
//

import ArgumentParser
import Digit
import Foundation

struct ListTargets: AsyncParsableCommand {
    // MARK: - Property
    static let configuration = CommandConfiguration(
        commandName: "list",
        abstract: "List known devices."
    )
    
    @OptionGroup var output: OutputOption
    
    // MARK: - Initializer
    // MARK: - Public
    func run() async throws {
        let devices = try DeviceSet().devices()
        
        try output.emit(devices) { plain(devices) }
    }
    
    // MARK: - Private
    private func plain(_ devices: [DeviceInfo]) -> String {
        TerminalTable().render(devices.map(\.terminalRow))
    }
}

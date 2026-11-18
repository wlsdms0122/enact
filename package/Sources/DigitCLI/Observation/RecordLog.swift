//
//  RecordLog.swift
//  DigitCLI
//
//  Created by JSilver on 11/11/26.
//

import ArgumentParser
import Digit
import Foundation

struct RecordLog: AsyncParsableCommand {
    // MARK: - Property
    static let configuration = CommandConfiguration(
        commandName: Operation.recordLog.rawValue,
        abstract: "Write the device's log stream until this command is stopped.",
        discussion: """
            Writes what `log stream` prints on the device, the lines --predicate \
            holds of where it is given, until interrupted (Ctrl-C, or SIGTERM \
            from whoever started it), and closes the file before exiting. It \
            runs beside a recording, a scenario and other logs.
            """
    )
    
    @OptionGroup var target: DeviceOption
    @Option(help: "file to write") var output: String
    @Option(help: "a `log stream` predicate the lines are filtered by") var predicate: String?
    
    // MARK: - Initializer
    // MARK: - Public
    func run() async throws {
        let device = try target.device()
        
        let recorded = try await device.recordLog(to: output, matching: predicate) {
            while !Task.isCancelled {
                try? await Task.sleep(nanoseconds: 100_000_000)
            }
        }
        
        if let lost = recorded.lost { throw lost }
        
        try recorded.outcome.get()
    }
    
    // MARK: - Private
}

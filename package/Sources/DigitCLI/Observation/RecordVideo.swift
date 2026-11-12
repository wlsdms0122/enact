//
//  RecordVideo.swift
//  DigitCLI
//
//  Created by JSilver on 8/16/26.
//

import ArgumentParser
import Digit
import Foundation

struct RecordVideo: AsyncParsableCommand {
    // MARK: - Property
    static let configuration = CommandConfiguration(
        commandName: Operation.recordVideo.rawValue,
        abstract: "Record the screen until this command is stopped.",
        discussion: """
            Runs until interrupted (Ctrl-C, or SIGTERM from whoever started it) \
            and closes the file before exiting. How long to record is the \
            caller's decision, so this process staying alive is the handle for \
            it. The recording belongs to this connection and no separate run \
            can reach it.
            """
    )
    
    @OptionGroup var target: DeviceOption
    @Option(help: "file to write") var output: String
    
    // MARK: - Initializer
    // MARK: - Public
    func run() async throws {
        let device = try target.device()
        
        let recorded = try await device.recordVideo(to: output) {
            while !Task.isCancelled {
                try? await Task.sleep(nanoseconds: 100_000_000)
            }
        }
        
        if let lost = recorded.lost { throw lost }
        
        try recorded.outcome.get()
    }
    
    // MARK: - Private
}

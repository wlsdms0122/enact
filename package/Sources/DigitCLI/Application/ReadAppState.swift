//
//  ReadAppState.swift
//  DigitCLI
//
//  Created by JSilver on 11/10/26.
//

import ArgumentParser
import Digit
import Foundation

struct ReadAppState: DeviceCommand {
    // MARK: - Property
    static let configuration = CommandConfiguration(
        commandName: Operation.appState.rawValue,
        abstract: "Print whether an app is not running, in the background or in the foreground.",
        discussion: """
            An app is in the foreground when the screen shows it. Reading which \
            app that is reads the accessibility tree once.
            """
    )
    
    @OptionGroup var target: DeviceOption
    @Option(name: .customLong("bundle-id"), help: "bundle identifier") var bundleID: String
    
    // MARK: - Initializer
    // MARK: - Public
    func perform(on device: Device) async throws -> AppState {
        try await device.run(AppStateOperator(bundleID: bundleID))
    }
    
    func show(_ answer: AppState) { print(answer.rawValue) }
    
    // MARK: - Private
}

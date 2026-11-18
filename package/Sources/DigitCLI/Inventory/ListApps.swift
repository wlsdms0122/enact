//
//  ListApps.swift
//  DigitCLI
//
//  Created by JSilver on 8/16/26.
//

import ArgumentParser
import Digit
import Foundation

struct ListApps: DeviceCommand {
    // MARK: - Property
    static let configuration = CommandConfiguration(
        commandName: Operation.listApps.rawValue,
        abstract: "List installed apps, with where their bundle and data sit.",
        discussion: """
            The plain form leaves out the paths, which are long enough to bury \
            the list; app-container answers where one app's files are.
            """
    )
    
    @OptionGroup var target: DeviceOption
    @OptionGroup var output: OutputOption
    
    // MARK: - Initializer
    // MARK: - Public
    func perform(on device: Device) async throws -> [InstalledApp] {
        try await device.run(ListAppsOperator())
    }
    
    func show(_ answer: [InstalledApp]) throws {
        try output.emit(answer) { plain(answer) }
    }
    
    // MARK: - Private
    private func plain(_ apps: [InstalledApp]) -> String {
        TerminalTable().render(apps.map { [$0.installKind, $0.bundleID, $0.name] })
    }
}

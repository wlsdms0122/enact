//
//  AppGroups.swift
//  DigitCLI
//
//  Created by JSilver on 8/16/26.
//

import ArgumentParser
import Digit
import Foundation

struct AppGroups: DeviceCommand {
    // MARK: - Property
    static let configuration = CommandConfiguration(
        commandName: Operation.appGroups.rawValue,
        abstract: "List the App Groups an app is in, and where each one sits.",
        discussion: "An app in no groups is an empty answer, not a failure."
    )
    
    @OptionGroup var target: DeviceOption
    @Option(name: .customLong("bundle-id"), help: "bundle identifier") var bundleID: String
    @OptionGroup var output: OutputOption
    
    // MARK: - Initializer
    // MARK: - Public
    func perform(on device: Device) async throws -> [String: String] {
        try await device.run(AppGroupsOperator(bundleID: bundleID))
    }
    
    func show(_ answer: [String: String]) throws {
        try output.emit(answer) {
            TerminalTable().render(answer.sorted { $0.key < $1.key }.map { [$0.key, $0.value] })
        }
    }
    
    // MARK: - Private
}

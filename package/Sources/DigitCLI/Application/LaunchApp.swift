//
//  LaunchApp.swift
//  DigitCLI
//
//  Created by JSilver on 8/16/26.
//

import ArgumentParser
import Digit
import Foundation

package struct LaunchApp: DeviceCommand {
    // MARK: - Property
    package static let configuration = CommandConfiguration(
        commandName: Operation.launchApp.rawValue,
        abstract: "Launch an app.",
        discussion: """
            An app already running is terminated and launched anew. --locale \
            and --language start the app under those settings for this run \
            only, leaving the device itself untouched. Prints the pid of the \
            process it started.
            """
    )
    
    @OptionGroup package var target: DeviceOption
    @Option(name: .customLong("bundle-id"), help: "bundle identifier") package var bundleID: String
    @Option(help: "locale to run under, e.g. en_US") package var locale: String?
    @Option(help: "language to run under, e.g. ko") package var language: String?
    @Argument(help: "arguments passed to the app") package var arguments: [String] = []
    
    // MARK: - Initializer
    package init() {}
    
    // MARK: - Public
    package func perform(on device: Device) async throws -> Int32 {
        try await device.run(
            LaunchAppOperator(
                bundleID: bundleID,
                arguments: arguments,
                locale: locale,
                language: language
            )
        )
    }
    
    package func show(_ answer: Int32) { print(answer) }
    
    // MARK: - Private
}

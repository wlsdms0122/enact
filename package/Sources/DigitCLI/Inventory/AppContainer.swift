//
//  AppContainer.swift
//  DigitCLI
//
//  Created by JSilver on 8/16/26.
//

import ArgumentParser
import Digit
import Foundation

struct AppContainer: DeviceCommand {
    // MARK: - Property
    static let configuration = CommandConfiguration(
        commandName: Operation.appContainer.rawValue,
        abstract: "Print where one app keeps its files.",
        discussion: """
            --container takes app (the bundle, the default), data (where the app \
            writes), or one App Group identifier. Which groups an app is in is a \
            different question with a different answer: app-groups.
            """
    )
    
    @OptionGroup var target: DeviceOption
    @Option(name: .customLong("bundle-id"), help: "bundle identifier") var bundleID: String
    @Option(help: "app, data, or an App Group identifier") var container: String = "app"
    
    // MARK: - Initializer
    // MARK: - Public
    func perform(on device: Device) async throws -> String {
        try await device.run(
            AppContainerOperator(bundleID: bundleID, container: try parse(container))
        )
    }
    
    func show(_ answer: String) { print(answer) }
    
    // MARK: - Private
    private func parse(_ text: String) throws -> AppContainerOperator.Container {
        switch text {
        case "app":
            return .bundle
        
        case "data":
            return .data
        
        default:
            guard text.contains(".") else {
                throw ValidationError(
                    "--container takes app, data, or an App Group identifier "
                        + "(got \(text))"
                )
            }
            
            return .group(text)
        }
    }
}

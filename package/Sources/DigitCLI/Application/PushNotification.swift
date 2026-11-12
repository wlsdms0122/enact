//
//  PushNotification.swift
//  DigitCLI
//
//  Created by JSilver on 8/16/26.
//

import ArgumentParser
import Digit
import Foundation

package struct PushNotification: DeviceCommand {
    // MARK: - Property
    package static let configuration = CommandConfiguration(
        commandName: Operation.pushNotification.rawValue,
        abstract: "Deliver a notification as though it had arrived over the air."
    )
    
    @OptionGroup package var target: DeviceOption
    @Option(name: .customLong("bundle-id"), help: "bundle identifier") package var bundleID: String
    @Option(help: "APNs payload as JSON, or - to read it from stdin") package var payload: String
    
    // MARK: - Initializer
    package init() {}
    
    // MARK: - Public
    package func reading(_ input: StandardInput) throws -> Self {
        guard payload == "-" else { return self }
        
        var command = self
        command.payload = try input.text(as: "payload")
        
        return command
    }
    
    package func perform(on device: Device) async throws -> Empty {
        try await device.run(try PushNotificationOperator(bundleID: bundleID, payload: payload))
        
        return Empty()
    }
    
    // MARK: - Private
}

//
//  SimulatorLifecycle.swift
//  Digit
//
//  Created by JSilver on 8/16/26.
//

import FBSimulatorControl
import Foundation

struct SimulatorLifecycle {
    // MARK: - Property
    // A busy host can take a minute before a booted device's accessibility answers.
    private static let accessibilityTimeout: Duration = .seconds(60)
    private static let accessibilityPollInterval: Duration = .milliseconds(250)
    
    var implementations: [Implementation] {
        [
            .perform(boot),
            .perform(shutdown),
            .perform(reboot),
            .perform(erase)
        ]
    }
    
    private let simulator: Simulator
    
    // MARK: - Initializer
    init(simulator: Simulator) {
        self.simulator = simulator
    }
    
    // MARK: - Public
    // MARK: - Private
    private func boot(_: BootOperator) async throws {
        try await simulator.lifecycle.boot(.default)
        try await waitForAccessibility(after: .boot)
    }
    
    private func shutdown(_: ShutdownOperator) async throws {
        try await simulator.power.shutdown()
    }
    
    private func reboot(_: RebootOperator) async throws {
        try await simulator.power.reboot()
        try await waitForAccessibility(after: .reboot)
    }
    
    private func erase(_: EraseOperator) async throws {
        try await simulator.erase()
    }
    
    // A device boots to its home screen, which answers once SpringBoard's accessibility
    // is ready to be read.
    private func waitForAccessibility(after operation: Operation) async throws {
        let reader = AccessibilityReader(simulator: simulator)
        let deadline = ContinuousClock.now + Self.accessibilityTimeout
        
        while try await !reader.answersAtScreenCenter() {
            guard ContinuousClock.now < deadline else {
                throw DigitError.commandFailed(
                    command: operation.rawValue,
                    message: "the device booted, but its accessibility did not answer within "
                        + "\(Self.accessibilityTimeout)"
                )
            }
            
            try await Task.sleep(for: Self.accessibilityPollInterval)
        }
    }
}

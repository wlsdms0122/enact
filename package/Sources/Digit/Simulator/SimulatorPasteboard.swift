//
//  SimulatorPasteboard.swift
//  Digit
//
//  Created by JSilver on 8/16/26.
//

import FBSimulatorControl
import Foundation

struct SimulatorPasteboard {
    // MARK: - Property
    var implementations: [Implementation] {
        [
            .perform(setPasteboard),
            .perform(readPasteboard)
        ]
    }
    
    private let simulator: Simulator
    private let simctl = Simctl()
    
    // MARK: - Initializer
    init(simulator: Simulator) {
        self.simulator = simulator
    }
    
    // MARK: - Public
    // MARK: - Private
    // A pasteboard can leave a write unapplied and say nothing, so the write
    // holds only once the pasteboard reads back what was written.
    private func setPasteboard(_ operation: SetPasteboardOperator) async throws {
        try simctl.run(["pbcopy", simulator.udid], input: operation.text)
        
        guard try simctl.run(["pbpaste", simulator.udid]) == operation.text else {
            throw DigitError.commandFailed(
                command: Operation.setPasteboard.rawValue,
                message: "the pasteboard does not hold what was written"
            )
        }
    }
    
    private func readPasteboard(_: ReadPasteboardOperator) async throws -> String {
        try simctl.run(["pbpaste", simulator.udid])
    }
}

//
//  DeviceCommand.swift
//  DigitCLI
//
//  Created by JSilver on 11/10/26.
//

import ArgumentParser
import Digit
import Foundation

// A command that does one thing to the device it names, so a session that
// already holds the device does it without opening the device again. Its
// answer is what a session prints for it, and what it shows is what it prints
// run on its own. What it takes from standard input it takes in reading, before
// it performs, since a session's standard input is the session's own.
package protocol DeviceCommand: AsyncParsableCommand {
    associatedtype Answer: Encodable & Sendable
    
    var target: DeviceOption { get }
    
    func reading(_ input: StandardInput) throws -> Self
    func perform(on device: Device) async throws -> Answer
    func show(_ answer: Answer) throws
}

extension DeviceCommand {
    package func run() async throws {
        let command = try reading(StandardInput())
        
        try command.show(await command.perform(on: target.device()))
    }
    
    package func reading(_: StandardInput) throws -> Self { self }
}

extension DeviceCommand where Answer == Empty {
    package func show(_: Empty) {}
}

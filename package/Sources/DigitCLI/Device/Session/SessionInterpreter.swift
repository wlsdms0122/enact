//
//  SessionInterpreter.swift
//  DigitCLI
//
//  Created by JSilver on 11/10/26.
//

import ArgumentParser
import Digit
import Foundation

// What a session does with each of its lines: reads the line as a command for
// the device it holds, and does the command, answering what it answered or
// why it was refused.
package struct SessionInterpreter: Sendable {
    // MARK: - Property
    private static let commands: [any DeviceCommand.Type] = DeviceGroup.configuration.subcommands
        .compactMap { command in command as? any DeviceCommand.Type }
    
    private let udid: String
    
    // MARK: - Initializer
    package init(udid: String) {
        self.udid = udid
    }
    
    // MARK: - Public
    // The command a line says, nil for a blank line.
    package func command(_ line: Data) throws(SessionFailure) -> (any DeviceCommand)? {
        let words: [String]
        
        do {
            words = try WordSplitter().split(StandardInput().text(line, as: "a command line"))
        } catch {
            throw SessionFailure(.argumentRefused, "\(error)")
        }
        
        guard let name = words.first else { return nil }
        
        guard let found = Self.commands.first(where: { command in command.configuration.commandName == name }) else {
            let names = Self.commands.compactMap { command in command.configuration.commandName }
            
            throw SessionFailure(
                .argumentRefused,
                "no command named '\(name)' for a session. These are: \(names.joined(separator: ", "))"
            )
        }
        
        return try command(Array(words.dropFirst()), as: found)
    }
    
    package func perform(_ command: any DeviceCommand, on device: Device) async -> SessionReply {
        do {
            return .result(try await command.perform(on: device))
        } catch {
            return .error(SessionFailure(performing: error))
        }
    }
    
    // MARK: - Private
    private func command<Command: DeviceCommand>(
        _ arguments: [String],
        as _: Command.Type
    ) throws(SessionFailure) -> Command {
        let name = Command.configuration.commandName ?? "\(Command.self)"
        let command: Command
        
        do {
            command = try Command.parse(["--udid", udid] + arguments).reading(.taken)
        } catch {
            throw SessionFailure(.argumentRefused, Command.fullMessage(for: error))
        }
        
        guard command.target.udid == udid else {
            throw SessionFailure(.argumentRefused, "\(name): this session holds \(udid), not \(command.target.udid)")
        }
        
        return command
    }
}

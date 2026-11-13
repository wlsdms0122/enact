//
//  RecordInput.swift
//  DigitCLI
//
//  Created by JSilver on 11/13/26.
//

import ArgumentParser
import Digit
import Foundation

struct RecordInput: AsyncParsableCommand {
    // MARK: - Property
    static let configuration = CommandConfiguration(
        commandName: Operation.recordInput.rawValue,
        abstract: "Write the input the device is given until this command is stopped.",
        discussion: """
            Each input is a line of JSON on standard output, or in --output, as \
            the device tells it, and the command runs until interrupted (Ctrl-C, \
            or SIGTERM from whoever started it). A person's touch in the \
            simulator's window and one this tool sends are alike. A gesture \
            carries the names the device recognized it by (tap, long press, \
            swipe up, …), where it began, the element accessibility answered \
            there, and the application's tree as it was then; a touch that moved \
            is told by its direction, and where it ended is not given. Keys typed \
            on a hardware keyboard, an application coming to the front and the \
            interface turning are lines of their own kinds. The recording is the \
            UI test recorder of the Xcode this tool runs with.
            """
    )
    
    @OptionGroup var target: DeviceOption
    @Option(help: "file to write, instead of standard output") var output: String?
    
    // MARK: - Initializer
    // MARK: - Public
    func run() async throws {
        let destination = try destination()
        let device = try target.device()
        let signals = SignalWaiter([SIGINT, SIGTERM])
        defer { signals.disarm() }
        
        let recording = try await device.run(
            RecordInputOperator { event in
                Self.write(event, to: destination)
            }
        )
        
        await signals.wait()
        
        try await recording.stop()
        try destination.close()
    }
    
    // MARK: - Private
    private func destination() throws -> FileHandle {
        guard let output else { return .standardOutput }
        
        guard FileManager.default.createFile(atPath: output, contents: nil),
            let handle = FileHandle(forWritingAtPath: output)
        else {
            throw ValidationError("cannot write \(output)")
        }
        
        return handle
    }
    
    // A write that fails means whoever reads the lines is gone, so the recording ends
    // with it, as a pipe's SIGPIPE would end it.
    private static func write(_ event: InputEvent, to destination: FileHandle) {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.sortedKeys, .withoutEscapingSlashes]
        
        do {
            try destination.write(contentsOf: try encoder.encode(event) + Data("\n".utf8))
        } catch {
            FileHandle.standardError.write(Data("enact: writing the input: \(error)\n".utf8))
            Foundation.exit(EXIT_FAILURE)
        }
    }
}

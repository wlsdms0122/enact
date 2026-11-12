//
//  LogStream.swift
//  Digit
//
//  Created by JSilver on 11/11/26.
//

import Foundation

// The device's unified log as `log stream` prints it, written to a file until
// it is stopped.
struct LogStream {
    // MARK: - Property
    // `log stream` prints its header once it streams, ends at once on a
    // predicate it cannot parse, and ends on an interrupt with 0.
    private static let startTimeout: Duration = .seconds(10)
    private static let stopTimeout: Duration = .seconds(5)
    private static let pollInterval: Duration = .milliseconds(100)
    
    private let udid: String
    
    // MARK: - Initializer
    init(udid: String) {
        self.udid = udid
    }
    
    // MARK: - Public
    func start(to path: String, matching predicate: String?) async throws -> Recording {
        guard FileManager.default.createFile(atPath: path, contents: nil) else {
            throw DigitError.recordingFailed(reason: "could not create \(path)")
        }
        
        let file = try FileHandle(forWritingTo: URL(fileURLWithPath: path))
        let failure = Pipe()
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/xcrun")
        process.arguments = ["simctl", "spawn", udid, "log", "stream"] + (predicate.map { ["--predicate", $0] } ?? [])
        process.standardInput = FileHandle.nullDevice
        process.standardOutput = file
        process.standardError = failure
        
        do {
            try process.run()
        } catch {
            try? file.close()
            
            throw error
        }
        
        nonisolated(unsafe) let streaming = process
        
        do {
            try await Self.waitForHeader(of: streaming, in: path, complaining: failure)
        } catch {
            try? await Self.stop(streaming, writing: file, draining: failure)
            
            throw error
        }
        
        return Recording {
            try await Self.stop(streaming, writing: file, draining: failure)
        }
    }
    
    // MARK: - Private
    private static func waitForHeader(of process: Process, in path: String, complaining failure: Pipe) async throws {
        let deadline = ContinuousClock.now + startTimeout
        
        while process.isRunning, size(of: path) == 0, ContinuousClock.now < deadline {
            try await Task.sleep(for: pollInterval)
        }
        
        guard process.isRunning else {
            // `log` says why on its last line; the lines before it are simctl's
            // own warnings.
            let complained = String(decoding: failure.fileHandleForReading.readDataToEndOfFile(), as: UTF8.self)
                .split(whereSeparator: \.isNewline)
                .last
                .map(String.init) ?? ""
            
            throw DigitError.recordingFailed(reason: "log stream exited \(process.terminationStatus): \(complained)")
        }
        
        guard size(of: path) > 0 else {
            throw DigitError.recordingFailed(reason: "log stream printed nothing within \(startTimeout)")
        }
        
        // What it complains of while streaming is no part of the log, but a pipe
        // left full would stall it.
        failure.fileHandleForReading.readabilityHandler = { handle in _ = handle.availableData }
    }
    
    private static func size(of path: String) -> Int {
        let attributes = try? FileManager.default.attributesOfItem(atPath: path)
        
        return (attributes?[.size] as? Int) ?? 0
    }
    
    private static func stop(_ process: Process, writing file: FileHandle, draining failure: Pipe) async throws {
        if process.isRunning { process.interrupt() }
        
        let ended = await exited(process, within: stopTimeout)
        
        if !ended { process.terminate() }
        
        failure.fileHandleForReading.readabilityHandler = nil
        try file.close()
        
        guard ended else {
            throw DigitError.recordingFailed(reason: "log stream did not end within \(stopTimeout) of an interrupt")
        }
        
        guard process.terminationStatus == 0 else {
            throw DigitError.recordingFailed(reason: "log stream exited \(process.terminationStatus)")
        }
    }
    
    // Waited apart from the caller's task, so a stop asked for after a cancel
    // still waits for the end instead of spinning through cancelled sleeps.
    private static func exited(_ process: Process, within timeout: Duration) async -> Bool {
        nonisolated(unsafe) let process = process
        
        return await Task {
            let deadline = ContinuousClock.now + timeout
            
            while process.isRunning {
                guard ContinuousClock.now < deadline else { return false }
                
                try? await Task.sleep(for: pollInterval)
            }
            
            return true
        }.value
    }
}

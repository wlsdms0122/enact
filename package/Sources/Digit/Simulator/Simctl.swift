//
//  Simctl.swift
//  Digit
//
//  Created by JSilver on 8/16/26.
//

import Foundation

struct Simctl {
    private final class Gathered: @unchecked Sendable {
        // MARK: - Property
        var data: Data {
            get {
                lock.lock()
                defer { lock.unlock() }
                
                return gathered
            }
            set {
                lock.lock()
                gathered = newValue
                lock.unlock()
            }
        }
        
        private let lock = NSLock()
        private var gathered = Data()
        
        // MARK: - Initializer
        // MARK: - Public
        // MARK: - Private
    }
    
    private final class Flag: @unchecked Sendable {
        // MARK: - Property
        var raised: Bool {
            lock.lock()
            defer { lock.unlock() }
            
            return flown
        }
        
        private let lock = NSLock()
        private var flown = false
        
        // MARK: - Initializer
        // MARK: - Public
        func raise() {
            lock.lock()
            flown = true
            lock.unlock()
        }
        
        // MARK: - Private
    }
    
    // MARK: - Property
    // MARK: - Initializer
    // MARK: - Public
    @discardableResult
    func run(_ arguments: [String], input: String? = nil) throws -> String {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/xcrun")
        process.arguments = ["simctl"] + arguments
        
        let (printed, complained) = try exchange(process, telling: input)
        let said = "simctl " + arguments.joined(separator: " ")
        
        guard process.terminationStatus == 0 else {
            throw DigitError.commandFailed(
                command: said,
                message: String(decoding: complained, as: UTF8.self)
                    .trimmingCharacters(in: .whitespacesAndNewlines)
            )
        }
        
        guard let text = String(bytes: printed, encoding: .utf8) else {
            throw DigitError.unreadableOutput(
                of: said,
                reason: "what it printed is not UTF-8 (\(printed.count) bytes)"
            )
        }
        
        return text
    }
    
    func exchange(
        _ process: Process,
        telling input: String?
    ) throws -> (printed: Data, complained: Data) {
        let output = Pipe()
        let failure = Pipe()
        let feed = Pipe()
        process.standardOutput = output
        process.standardError = failure
        process.standardInput = feed
        
        try process.run()
        
        let served = DispatchGroup()
        let complained = Gathered()
        let draining = failure.fileHandleForReading
        
        DispatchQueue.global().async(group: served) {
            complained.data = draining.readDataToEndOfFile()
        }
        
        let feeding = feed.fileHandleForWriting
        _ = fcntl(feeding.fileDescriptor, F_SETNOSIGPIPE, 1)
        
        let payload = input.map { Data($0.utf8) }
        let refused = Flag()
        
        DispatchQueue.global().async(group: served) {
            if let payload {
                do {
                    try feeding.write(contentsOf: payload)
                } catch {
                    refused.raise()
                }
            }
            
            try? feeding.close()
        }
        
        let printed = output.fileHandleForReading.readDataToEndOfFile()
        served.wait()
        process.waitUntilExit()
        
        guard !refused.raised || process.terminationStatus != 0 else {
            throw DigitError.commandFailed(
                command: (process.arguments ?? []).joined(separator: " "),
                message: "exited 0 while refusing its input"
            )
        }
        
        return (printed, complained.data)
    }
    
    // MARK: - Private
}

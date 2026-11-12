//
//  DeviceLock.swift
//  Digit
//
//  Created by JSilver on 8/16/26.
//

import Foundation

public struct DeviceLock: Sendable {
    public enum Held: String, Sendable, CaseIterable {
        case device
        case video
        
        var suffix: String { self == .device ? ".lock" : ".\(rawValue).lock" }
    }
    
    private struct Handle {
        let descriptor: Int32
        
        func release() {
            // A child being spawned holds a copy of this descriptor until its exec,
            // so closing alone can leave the lock held after release returns.
            flock(descriptor, LOCK_UN)
            close(descriptor)
        }
    }
    
    // MARK: - Property
    public let directory: URL
    
    // MARK: - Initializer
    public init(directory: URL) {
        self.directory = directory
    }
    
    public init() {
        if let override = ProcessInfo.processInfo.environment["DIGIT_LOCK_DIR"],
            !override.isEmpty {
            self.init(directory: URL(fileURLWithPath: override, isDirectory: true))
        } else {
            self.init(
                directory: FileManager.default.homeDirectoryForCurrentUser
                    .appendingPathComponent(".config/digit/lock", isDirectory: true)
            )
        }
    }
    
    // MARK: - Public
    public func path(for udid: String, holding held: Held = .device) throws -> URL {
        guard !udid.isEmpty, !udid.contains("/"), udid != ".", udid != ".." else {
            throw DigitError.malformedPayload(reason: "not a udid: '\(udid)'")
        }
        
        return directory.appendingPathComponent("\(udid)\(held.suffix)", isDirectory: false)
    }
    
    public func withExclusiveAccess<T>(
        to udid: String,
        holding held: Held = .device,
        _ body: () throws -> T
    ) throws -> T {
        let handle = try acquire(udid, held)
        defer { handle.release() }
        
        return try body()
    }
    
    public func withExclusiveAccess<T>(
        to udid: String,
        holding held: Held = .device,
        _ body: () async throws -> T
    ) async throws -> T {
        let handle = try acquire(udid, held)
        defer { handle.release() }
        
        return try await body()
    }
    
    // MARK: - Private
    private func acquire(_ udid: String, _ held: Held) throws -> Handle {
        let path = try path(for: udid, holding: held)
        
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        
        let descriptor = open(path.path, O_CREAT | O_RDWR | O_CLOEXEC, 0o644)
        
        guard descriptor >= 0 else {
            throw DigitError.commandFailed(
                command: "lock \(udid)",
                message: String(cString: strerror(errno))
            )
        }
        
        guard flock(descriptor, LOCK_EX | LOCK_NB) == 0 else {
            let reason = errno
            close(descriptor)
            
            guard reason == EWOULDBLOCK else {
                throw DigitError.commandFailed(
                    command: "lock \(udid)",
                    message: String(cString: strerror(reason))
                )
            }
            
            throw DigitError.deviceBusy(udid: udid)
        }
        
        return Handle(descriptor: descriptor)
    }
}

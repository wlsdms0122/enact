//
//  VideoLease.swift
//  Digit
//
//  Created by JSilver on 8/16/26.
//

import Foundation

struct VideoLease {
    struct Held: Sendable {
        let marker: URL
        
        func closed() throws {
            guard FileManager.default.fileExists(atPath: marker.path) else { return }
            
            do {
                try FileManager.default.removeItem(at: marker)
            } catch {
                throw DigitError.recordingFailed(reason: "could not mark the video closed at \(marker.path): \(error)")
            }
        }
    }
    
    // MARK: - Property
    private let lock: DeviceLock
    
    // MARK: - Initializer
    init(lock: DeviceLock) {
        self.lock = lock
    }
    
    // MARK: - Public
    func marker(for udid: String) throws -> URL {
        let path = try lock.path(for: udid, holding: .video)
        
        return path.deletingLastPathComponent()
            .appendingPathComponent("\(udid).\(DeviceLock.Held.video.rawValue).open", isDirectory: false)
    }
    
    func recording<T>(
        on udid: String,
        to path: String,
        _ body: (Held) async throws -> T
    ) async throws -> T {
        try await lock.withExclusiveAccess(to: udid, holding: .video) {
            let marker = try marker(for: udid)
            
            guard !FileManager.default.fileExists(atPath: marker.path) else {
                throw DigitError.videoUnclosed(
                    udid: udid,
                    marker: marker.path,
                    left: (try? String(contentsOf: marker, encoding: .utf8))?.trimmingCharacters(
                        in: .whitespacesAndNewlines
                    ) ?? ""
                )
            }
            
            let opened = "pid \(ProcessInfo.processInfo.processIdentifier) tried to record video to \(path)"
            do {
                try Data(opened.utf8).write(to: marker, options: .atomic)
            } catch {
                throw DigitError.recordingFailed(reason: "could not mark the video open at \(marker.path): \(error)")
            }
            
            return try await body(Held(marker: marker))
        }
    }
    
    // MARK: - Private
}

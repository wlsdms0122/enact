//
//  RecordingLog.swift
//  EnactWarp
//
//  Created by JSilver on 10/31/26.
//

import Foundation

// The videos and logs a run landed, in the order they closed, and the ones it lost.
package final class RecordingLog: @unchecked Sendable {
    // MARK: - Property
    package var landed: [String] { lock.withLock { landedPaths } }
    package var lost: [LostRecording] { lock.withLock { lostRecordings } }
    
    private let lock = NSLock()
    private var landedPaths: [String] = []
    private var lostRecordings: [LostRecording] = []
    
    // MARK: - Initializer
    package init() {}
    
    // MARK: - Public
    func land(_ path: String) {
        lock.withLock { landedPaths.append(path) }
    }
    
    func lose(_ path: String, because reason: String) {
        lock.withLock { lostRecordings.append(LostRecording(path: path, reason: reason)) }
    }
    
    // MARK: - Private
}

//
//  DeviceStage.swift
//  EnactWarpTests
//
//  Created by JSilver on 10/31/26.
//

import Foundation
import Warp
@testable import Digit
@testable import EnactWarp

// A recording device behind a run, with a lock and an out dir of its own
// that go away with it.
struct DeviceStage {
    // MARK: - Property
    let backend: RecordingBackend
    let directory: URL
    let environment: EnactEnvironment
    
    // MARK: - Initializer
    init(elements: [Element] = [], failure: (any Error)? = nil, closing: (any Error)? = nil) throws {
        let directory = URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true)
            .appendingPathComponent("enact-test-\(UUID().uuidString)", isDirectory: true)
        let backend = try RecordingBackend(elements: elements, failure: failure, closing: closing)
        
        self.backend = backend
        self.directory = directory
        self.environment = EnactEnvironment(
            device: Device(backend: backend, lock: DeviceLock(directory: directory.appendingPathComponent("lock"))),
            outputDirectory: OutputDirectory(url: directory.appendingPathComponent("out"))
        )
    }
    
    // MARK: - Public
    // Runs a scenario on this device and cleans up after it.
    func run(_ text: String) async throws -> Warp.Value {
        defer { try? FileManager.default.removeItem(at: directory) }
        
        return try await EnactWarpTests.run(text, environment: environment)
    }
    
    // MARK: - Private
}

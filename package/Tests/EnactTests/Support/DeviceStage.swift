//
//  DeviceStage.swift
//  EnactTests
//
//  Created by JSilver on 10/31/26.
//

import Foundation
import Warp
@testable import Digit
@testable import Enact
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
    // Runs a scenario through the runner on this device and reports it.
    func report(
        _ text: String,
        arguments: [Warp.Name: Warp.Value] = [:],
        stop: StopPoint? = nil,
        lock: DeviceLock? = nil,
        sink: Journal.Sink? = nil
    ) async throws -> Report {
        defer { try? FileManager.default.removeItem(at: directory) }
        
        let vocabulary = try EnactVocabulary.shipped.get()
        let scenario = try document(of: text)
        
        return await ScenarioRunner(vocabulary: vocabulary).run(
            try await image(of: text),
            entry: entry,
            arguments: arguments,
            scenario: "test",
            statements: StatementTree(procedures: scenario.procedures, entry: entry),
            device: environment.device,
            lock: lock ?? DeviceLock(directory: directory.appendingPathComponent("run-lock")),
            outputDirectory: environment.outputDirectory,
            stop: stop,
            sink: sink
        )
    }
    
    // MARK: - Private
}

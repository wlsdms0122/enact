//
//  Engine.swift
//  Enact
//
//  Created by JSilver on 10/31/26.
//

import Digit
import EnactWarp
import Foundation
import Warp

// Builds scenarios over Enact's vocabulary and runs them on a device. It
// reports what a run did and does not judge it: what counts as success
// depends on what the scenario is used for.
public struct Engine: Sendable {
    // MARK: - Property
    private let builder: ScenarioBuilder
    
    // MARK: - Initializer
    public init() throws {
        self.builder = ScenarioBuilder(vocabulary: try EnactVocabulary())
    }
    
    // MARK: - Public
    // The scenario under the name and every one it calls, read and built as a
    // run reads and builds them first.
    public func check(_ name: String, store: ScenarioStore) async throws -> Scenario {
        try await Scenario(name: name, loader: ScenarioLoader(vocabulary: builder.vocabulary, store: store), builder: builder)
    }
    
    public func run(
        _ name: String,
        store: ScenarioStore,
        udid: String,
        inputs: [String: String] = [:],
        outputDirectory: URL,
        stop: StopPoint? = nil,
        events: Journal.Sink? = nil,
        record: Bool = false
    ) async -> Report {
        let refusing = Journal(scenario: name, device: udid, vocabulary: [], enums: [], sink: events)
        let directory = OutputDirectory(url: outputDirectory)
        let runner = ScenarioRunner(vocabulary: builder.vocabulary)
        let scenario: Scenario
        let arguments: [Warp.Name: Warp.Value]
        let device: Device
        
        do {
            scenario = try await check(name, store: store)
        } catch {
            return await finished(refusing.refuse(.loadFailed, "\(error)"), record: record, in: directory, by: runner)
        }
        
        guard let entry = scenario.entry else {
            let missing = ScenarioLookupError.entryMissing(name: name)
            
            return await finished(refusing.refuse(.loadFailed, "\(missing)"), record: record, in: directory, by: runner)
        }
        
        do {
            arguments = try entry.arguments(from: inputs)
        } catch {
            return await finished(refusing.refuse(.inputsRejected, "\(error)"), record: record, in: directory, by: runner)
        }
        
        do {
            let devices = DeviceSet()
            
            try devices.loadFrameworks()
            device = try devices.open(udid: try devices.resolve(udid: udid))
        } catch {
            return await finished(refusing.refuse(.deviceUnavailable, "\(error)"), record: record, in: directory, by: runner)
        }
        
        let report = await runner.run(
            scenario.image,
            entry: entry.name,
            arguments: arguments,
            scenario: name,
            statements: entry.statements,
            device: device,
            lock: DeviceLock(),
            outputDirectory: directory,
            stop: stop,
            sink: events
        )
        
        return await finished(report, record: record, in: directory, by: runner)
    }
    
    // MARK: - Private
    private func finished(
        _ report: Report,
        record: Bool,
        in directory: OutputDirectory,
        by runner: ScenarioRunner
    ) async -> Report {
        record ? await runner.written(report, in: directory) : report
    }
}

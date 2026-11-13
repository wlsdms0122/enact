//
//  ScenarioRunner.swift
//  Enact
//
//  Created by JSilver on 10/31/26.
//

import Digit
import EnactWarp
import Foundation
import Warp

// Runs a built scenario on one device and reports what it did. Before the
// first statement it refuses a stop no statement answers to, a device that
// does none of what the scenario can ask, and a device another run holds.
struct ScenarioRunner: Sendable {
    // MARK: - Property
    let vocabulary: EnactVocabulary
    
    // MARK: - Initializer
    init(vocabulary: EnactVocabulary) {
        self.vocabulary = vocabulary
    }
    
    // MARK: - Public
    func run(
        _ image: Image,
        entry: Warp.Name,
        arguments: [Warp.Name: Warp.Value] = [:],
        scenario: String,
        statements: StatementTree,
        device: Device,
        lock: DeviceLock,
        outputDirectory: OutputDirectory,
        stop: StopPoint? = nil,
        sink: Journal.Sink? = nil
    ) async -> Report {
        let journal = Journal(
            scenario: scenario,
            device: device.info.udid,
            vocabulary: Set(vocabulary.linkables.flatMap { module in module.procedures.keys.map(\.spelling) }),
            enums: Set(image.types.types.compactMap { declared, type in
                guard case .enum = type else { return nil }
                
                return declared
            }),
            sink: sink
        )
        
        // A stop is an address of the scenario's statement tree; whether the run
        // reaches it is the run's to say.
        let address = stop.map { stop in
            StatementAddress(stop.address.split(separator: "/", omittingEmptySubsequences: false).map(String.init))
        }
        
        if let stop, let address, !statements.contains(address) {
            return journal.refuse(.stopUnknown, unknownStop(stop, at: address, in: statements, of: scenario))
        }
        
        let asked: [Digit.Operation: Set<String>]
        
        do {
            asked = try EnactVocabulary.operations(reachedFrom: entry, in: image)
        } catch {
            return journal.refuse(.loadFailed, "\(error)")
        }
        
        if let missing = asked.keys.sorted(by: { one, other in one.rawValue < other.rawValue }).first(where: { operation in
            !device.capabilities.contains(operation)
        }) {
            let verbs = (asked[missing] ?? []).sorted().joined(separator: ", ")
            
            return journal.refuse(.unsupportedDevice, "\(verbs): \(missing.rawValue) is not available on this device")
        }
        
        do {
            return try await lock.withExclusiveAccess(to: device.info.udid) {
                await carry(
                    image,
                    entry: entry,
                    arguments: arguments,
                    journal: journal,
                    environment: EnactEnvironment(device: device, outputDirectory: outputDirectory),
                    stop: stop,
                    at: address
                )
            }
        } catch DigitError.deviceBusy {
            return journal.refuse(.deviceBusy, "\(device.info.udid) is held by another run")
        } catch {
            return journal.refuse(.deviceUnavailable, "\(error)")
        }
    }
    
    // Writes the report into the out dir and says where.
    func written(_ report: Report, in outputDirectory: OutputDirectory) async -> Report {
        var written = report
        
        do {
            try await outputDirectory.write("report", ext: "json") { destination in
                written.reportPath = destination.path
                try Data(written.json().utf8).write(to: destination)
            }
        } catch {
            written.reportPath = nil
        }
        
        return written
    }
    
    // MARK: - Private
    // Names the addresses that end in the same statement, as a stop written
    // short of where it stands.
    private func unknownStop(
        _ stop: StopPoint,
        at address: StatementAddress,
        in statements: StatementTree,
        of scenario: String
    ) -> String {
        let option = stop.before ? "--stop-before" : "--stop-at"
        let refusal = "\(option) \(stop.address): no statement of \(scenario) stands at this address"
        
        guard let last = address.segments.last else { return refusal }
        
        let named = statements.addresses(named: last).map(\.description)
        
        guard !named.isEmpty else { return refusal }
        
        return refusal + ". Statements named '\(last)': " + named.joined(separator: ", ")
    }
    
    private func carry(
        _ image: Image,
        entry: Warp.Name,
        arguments: [Warp.Name: Warp.Value],
        journal: Journal,
        environment: EnactEnvironment,
        stop: StopPoint?,
        at address: StatementAddress?
    ) async -> Report {
        let running = RunningTask()
        
        journal.bound(
            at: address,
            before: stop?.before ?? false,
            evidence: { address in await evidence(at: address, in: environment) }
        ) {
            running.cancel()
        }
        journal.began()
        
        let ran = await running.run {
            try await Executor(observer: journal, environment: environment).run(image, entry: entry, arguments: arguments)
        }
        let stop = stop.map { stop in Report.Stop(at: stop.address, before: stop.before, reached: journal.reachedStop) }
        
        switch ran {
        case let .success(value):
            return journal.finish(
                outcome: .completed,
                detail: nil,
                result: value,
                recordings: environment.recordings.landed,
                lostRecordings: environment.recordings.lost,
                stop: stop
            )
        
        case let .failure(error):
            if journal.reachedStop, StepFailure(failing: error).kind == .interrupted {
                return journal.finish(
                    outcome: .completed,
                    detail: nil,
                    result: nil,
                    recordings: environment.recordings.landed,
                    lostRecordings: environment.recordings.lost,
                    stop: stop
                )
            }
            
            let failure = StepFailure(failing: error)
            
            return journal.finish(
                outcome: .aborted,
                detail: "\(failure.kind.rawValue): \(failure.detail)",
                result: nil,
                recordings: environment.recordings.landed,
                lostRecordings: environment.recordings.lost,
                stop: stop
            )
        }
    }
    
    // What the screen showed when a statement failed: a screenshot and the
    // tree, each in the out dir under the statement's address.
    private func evidence(at address: String, in environment: EnactEnvironment) async -> StepReport.Evidence? {
        let stem = "failed-" + address.replacingOccurrences(of: "/", with: "-")
        var screenshot: String?
        var tree: String?
        
        if let image = try? await environment.device.run(ScreenshotOperator(format: .png)) {
            screenshot = try? await environment.outputDirectory.write(stem, ext: "png") { destination in
                try image.write(to: destination)
                
                return destination.path
            }
        }
        
        if let elements = try? await environment.device.run(DescribeUIOperator()) {
            let encoder = JSONEncoder()
            
            encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
            tree = try? await environment.outputDirectory.write(stem, ext: "json") { destination in
                try encoder.encode(elements).write(to: destination)
                
                return destination.path
            }
        }
        
        guard screenshot != nil || tree != nil else { return nil }
        
        return StepReport.Evidence(screenshot: screenshot, tree: tree)
    }
}

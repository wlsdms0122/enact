//
//  Device.swift
//  Digit
//
//  Created by JSilver on 8/16/26.
//

import Foundation

public struct Device: @unchecked Sendable {
    // MARK: - Property
    public var info: DeviceInfo { backend.info }
    public var capabilities: Set<Operation> { dispatchTable.operations }
    
    private let backend: DeviceBackend
    private let dispatchTable: DispatchTable
    private let lock: DeviceLock
    
    // MARK: - Initializer
    init(backend: DeviceBackend, lock: DeviceLock = DeviceLock()) {
        self.backend = backend
        self.dispatchTable = backend.dispatchTable
        self.lock = lock
    }
    
    // MARK: - Public
    public func run<O: Operator>(_ operation: O) async throws -> O.Result {
        guard let perform = dispatchTable.body(for: O.self) else {
            throw CapabilityError(operation: O.operation, target: backend.info)
        }
        
        // A cancelled task starts nothing on the device.
        guard !Task.isCancelled else { throw DigitError.interrupted }
        
        // What the device's frameworks throw leaves Digit as a DigitError, so a
        // caller tells every failure of an operation by Digit's own errors.
        do {
            return try await perform(operation)
        } catch let error as DigitError {
            throw error
        } catch let error as CapabilityError {
            throw error
        } catch is CancellationError {
            throw DigitError.interrupted
        } catch {
            throw DigitError.commandFailed(command: O.operation.rawValue, message: Self.message(of: error))
        }
    }
    
    // The two operations that are more than a dispatch record while the work
    // runs, and hand back how the work went beside what came of the recording:
    // one the recorder could not close is lost, whatever the work did. One
    // that never started, so the work never ran, is thrown as
    // `UnstartedRecording`; a run stopped while it was starting is `interrupted`.
    // A device records one video at a time.
    public func recordVideo<Work: Sendable>(
        to path: String,
        while running: @escaping @Sendable () async throws -> Work
    ) async throws -> Recorded<Work> {
        guard let start = dispatchTable.body(for: RecordVideoOperator.self) else {
            throw CapabilityError(operation: .recordVideo, target: backend.info)
        }
        
        do {
            return try await VideoLease(lock: lock).recording(on: backend.info.udid, to: path) { lease in
                // A video is closed once its recorder stops, and stays open where it
                // does not.
                try await record(
                    starting: {
                        let recording = try await start(RecordVideoOperator(path: path))
                        
                        return Recording {
                            try await recording.stop()
                            try lease.closed()
                        }
                    },
                    while: running
                )
            }
        } catch let unstarted as UnstartedRecording {
            throw unstarted
        } catch DigitError.interrupted {
            throw DigitError.interrupted
        } catch {
            throw UnstartedRecording(reason: Self.recorderFailure(error, while: "opening"))
        }
    }
    
    // Logs stream beside one another and beside a video.
    public func recordLog<Work: Sendable>(
        to path: String,
        matching predicate: String?,
        while running: @escaping @Sendable () async throws -> Work
    ) async throws -> Recorded<Work> {
        guard let start = dispatchTable.body(for: RecordLogOperator.self) else {
            throw CapabilityError(operation: .recordLog, target: backend.info)
        }
        
        return try await record(
            starting: { try await start(RecordLogOperator(path: path, predicate: predicate)) },
            while: running
        )
    }
    
    // MARK: - Private
    private func record<Work: Sendable>(
        starting start: () async throws -> Recording,
        while running: @escaping @Sendable () async throws -> Work
    ) async throws -> Recorded<Work> {
        let signals = SignalWaiter([SIGINT, SIGTERM])
        defer { signals.disarm() }
        
        let recording: Recording
        
        // A signal sent to the whole process group can end the recorder before
        // it starts, so a start that fails after one is the run stopped.
        do {
            recording = try await start()
        } catch {
            if error is CancellationError || signals.hasArrived { throw DigitError.interrupted }
            
            throw UnstartedRecording(reason: Self.recorderFailure(error, while: "starting"))
        }
        let work = Task { try await running() }
        let onSignal = Task {
            await signals.wait()
            work.cancel()
        }
        
        let outcome = await withTaskCancellationHandler {
            await work.result
        } onCancel: {
            work.cancel()
        }
        
        onSignal.cancel()
        
        var lost: DigitError?
        
        do {
            let stopping = Task { try await recording.stop() }
            try await stopping.value
        } catch {
            lost = Self.recorderFailure(error, while: "closing")
        }
        
        return Recorded(outcome: outcome.mapError(Self.carried), lost: lost)
    }
    
    // What the work failed with, as the caller is told it.
    private static func carried(_ error: any Error) -> any Error {
        error is CancellationError ? DigitError.interrupted : error
    }
    
    // A framework error's own description where it writes one, and what it is
    // otherwise.
    private static func message(of error: any Error) -> String {
        if let described = (error as? LocalizedError)?.errorDescription { return described }
        
        let bridged = error as NSError
        
        guard bridged.userInfo[NSLocalizedDescriptionKey] != nil else { return String(describing: error) }
        
        return bridged.localizedDescription
    }
    
    private static func recorderFailure(_ error: any Error, while doing: String) -> DigitError {
        if let digit = error as? DigitError { return digit }
        
        return .recordingFailed(reason: "\(doing) the recording: \(error)")
    }
}

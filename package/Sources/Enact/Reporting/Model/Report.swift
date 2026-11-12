//
//  Report.swift
//  Enact
//
//  Created by JSilver on 8/16/26.
//

import EnactWarp
import Foundation

public struct Report: Sendable, Encodable {
    public enum Outcome: String, Sendable, Encodable {
        case completed
        case aborted
        case refused
    }
    
    public enum Refusal: String, Sendable, Encodable {
        case loadFailed = "load_failed"
        case deviceUnavailable = "device_unavailable"
        case deviceBusy = "device_busy"
        case unsupportedDevice = "unsupported_device"
        case stopUnknown = "stop_unknown"
        case inputsRejected = "inputs_rejected"
    }
    
    public struct Stop: Sendable, Encodable {
        // MARK: - Property
        public let at: String
        public let reached: Bool
        
        // MARK: - Initializer
        // MARK: - Public
        // MARK: - Private
    }
    
    // MARK: - Property
    public let scenario: String
    public let device: String
    public let outcome: Outcome
    public let failures: [String]
    public let durationMs: Int
    public internal(set) var steps: [StepReport]
    // What the scenario returned, where it ran to the end.
    public let result: ReportedValue?
    public let recordings: [String]
    public let lostRecordings: [LostRecording]
    public let refused: Refusal?
    public let detail: String?
    public let stop: Stop?
    public internal(set) var reportPath: String?
    
    // MARK: - Initializer
    init(
        scenario: String,
        device: String,
        outcome: Outcome,
        failures: [String],
        durationMs: Int,
        steps: [StepReport],
        result: ReportedValue?,
        recordings: [String],
        lostRecordings: [LostRecording] = [],
        refused: Refusal? = nil,
        detail: String? = nil,
        stop: Stop? = nil,
        reportPath: String? = nil
    ) {
        self.scenario = scenario
        self.device = device
        self.outcome = outcome
        self.failures = failures
        self.durationMs = durationMs
        self.steps = steps
        self.result = result
        self.recordings = recordings
        self.lostRecordings = lostRecordings
        self.refused = refused
        self.detail = detail
        self.stop = stop
        self.reportPath = reportPath
    }
    
    // MARK: - Public
    public static func refusing(
        _ reason: Refusal,
        _ detail: String,
        scenario: String,
        device: String = ""
    ) -> Report {
        Report(
            scenario: scenario,
            device: device,
            outcome: .refused,
            failures: [],
            durationMs: 0,
            steps: [],
            result: nil,
            recordings: [],
            refused: reason,
            detail: detail
        )
    }
    
    // MARK: - Private
}

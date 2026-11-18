//
//  StepFailure.swift
//  EnactWarp
//
//  Created by JSilver on 8/16/26.
//

import Digit
import Foundation
import Warp
import WarpStandard

public struct StepFailure: Sendable, Encodable, RecoverableFailure {
    public enum Kind: String, Sendable, Encodable {
        case timedOut = "timed_out"
        case deviceRefused = "device_refused"
        case referenceUnfit = "reference_unfit"
        case argumentRefused = "argument_refused"
        case recordingFailed = "recording_failed"
        case interrupted
        case aborted
    }
    
    // MARK: - Property
    public let kind: Kind
    public let detail: String
    
    // The kind is the failure's type, so a scenario's catch tells kinds apart.
    public var type: String { kind.rawValue }
    public var message: String { detail }
    
    // MARK: - Initializer
    init(_ kind: Kind, _ detail: String) {
        self.kind = kind
        self.detail = detail
    }
    
    // What a run failed with, as the kind a catch names it by.
    package init(failing error: any Error) {
        switch error {
        case let failure as StepFailure:
            self = failure
        
        case is CancellationError, DigitError.interrupted:
            self.init(.interrupted, "interrupted")
        
        case let aborted as Aborted:
            self.init(.aborted, aborted.message)
        
        case let refused as CastRefused:
            self.init(.referenceUnfit, refused.message)
        
        case let digit as DigitError:
            self.init(digit)
        
        default:
            self.init(.deviceRefused, "\(error)")
        }
    }
    
    // A refusal of what the scenario handed is the scenario's; any other is the device's.
    init(_ error: DigitError) {
        self.init(error.refusesArgument ? .argumentRefused : .deviceRefused, "\(error)")
    }
    
    // MARK: - Public
    // MARK: - Private
}

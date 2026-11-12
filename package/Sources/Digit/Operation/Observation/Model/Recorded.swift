//
//  Recorded.swift
//  Digit
//
//  Created by JSilver on 11/1/26.
//

import Foundation

// What came of a work run under a recording, side by side: how the work went,
// and why the recording was lost where the recorder could not close it.
// Neither outranks the other; each is said as it was.
public struct Recorded<Work: Sendable>: Sendable {
    // MARK: - Property
    public let outcome: Result<Work, any Error>
    public let lost: DigitError?
    
    // MARK: - Initializer
    init(outcome: Result<Work, any Error>, lost: DigitError?) {
        self.outcome = outcome
        self.lost = lost
    }
    
    // MARK: - Public
    // MARK: - Private
}

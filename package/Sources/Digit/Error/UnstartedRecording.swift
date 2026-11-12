//
//  UnstartedRecording.swift
//  Digit
//
//  Created by JSilver on 11/1/26.
//

import Foundation

// A recording the recorder could not open or start, so the work it was to run
// beside never ran. The reason is the recorder's.
public struct UnstartedRecording: Error, CustomStringConvertible {
    // MARK: - Property
    public let reason: DigitError
    
    public var description: String { "the recording never started: \(reason)" }
    
    // MARK: - Initializer
    init(reason: DigitError) {
        self.reason = reason
    }
    
    // MARK: - Public
    // MARK: - Private
}

//
//  RecordInputOperator.swift
//  Digit
//
//  Created by JSilver on 11/13/26.
//

import Foundation

// Hands each input the device is given to the sink, in the order the device tells
// them, until the recording is stopped.
public struct RecordInputOperator: Operator {
    public typealias Result = InputRecording
    
    // MARK: - Property
    public static let operation = Operation.recordInput
    
    public let sink: @Sendable (InputEvent) -> Void
    
    // MARK: - Initializer
    public init(sink: @escaping @Sendable (InputEvent) -> Void) {
        self.sink = sink
    }
    
    // MARK: - Public
    // MARK: - Private
}

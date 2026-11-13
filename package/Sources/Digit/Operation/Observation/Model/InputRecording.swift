//
//  InputRecording.swift
//  Digit
//
//  Created by JSilver on 11/13/26.
//

import Foundation

public struct InputRecording: Sendable {
    // MARK: - Property
    private let loss: @Sendable () async -> DigitError?
    private let end: @Sendable () async throws -> Void
    
    // MARK: - Initializer
    init(loss: @escaping @Sendable () async -> DigitError?, end: @escaping @Sendable () async throws -> Void) {
        self.loss = loss
        self.end = end
    }
    
    // MARK: - Public
    // Waits for the recording to end: why it was lost where the device ended it,
    // nil once it is stopped.
    public func lost() async -> DigitError? {
        await loss()
    }
    
    // Ends the recording. Nothing is told once it returns.
    public func stop() async throws {
        try await end()
    }
    
    // MARK: - Private
}

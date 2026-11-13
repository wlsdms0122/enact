//
//  InputRecording.swift
//  Digit
//
//  Created by JSilver on 11/13/26.
//

import Foundation

public struct InputRecording: Sendable {
    // MARK: - Property
    private let end: @Sendable () async throws -> Void
    
    // MARK: - Initializer
    init(end: @escaping @Sendable () async throws -> Void) {
        self.end = end
    }
    
    // MARK: - Public
    // Ends the recording. Nothing is told once it returns.
    public func stop() async throws {
        try await end()
    }
    
    // MARK: - Private
}

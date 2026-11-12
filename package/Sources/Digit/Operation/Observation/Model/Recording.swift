//
//  Recording.swift
//  Digit
//
//  Created by JSilver on 8/16/26.
//

import Foundation

struct Recording: @unchecked Sendable {
    // MARK: - Property
    private let end: @Sendable () async throws -> Void
    
    // MARK: - Initializer
    init(end: @escaping @Sendable () async throws -> Void) {
        self.end = end
    }
    
    // MARK: - Public
    func stop() async throws {
        try await end()
    }
    
    // MARK: - Private
}

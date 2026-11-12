//
//  Heard.swift
//  EnactTests
//
//  Created by JSilver on 10/31/26.
//

import Foundation

// What a sink was told, in order.
final class Heard: @unchecked Sendable {
    // MARK: - Property
    var events: [String] { lock.withLock { told } }
    
    private let lock = NSLock()
    private var told: [String] = []
    
    // MARK: - Initializer
    // MARK: - Public
    func append(_ event: String) {
        lock.withLock { told.append(event) }
    }
    
    // MARK: - Private
}

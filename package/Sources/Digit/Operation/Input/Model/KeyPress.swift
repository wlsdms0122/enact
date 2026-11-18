//
//  KeyPress.swift
//  Digit
//
//  Created by JSilver on 8/16/26.
//

import Foundation

public struct KeyPress: Sendable, Equatable {
    // MARK: - Property
    public let code: UInt32
    public let shifted: Bool
    
    private static let held: ClosedRange<UInt32> = 224...231
    
    // MARK: - Initializer
    public init?(code: UInt32, shifted: Bool = false) {
        guard !Self.held.contains(code) else { return nil }
        
        self.code = code
        self.shifted = shifted
    }
    
    // MARK: - Public
    // MARK: - Private
}

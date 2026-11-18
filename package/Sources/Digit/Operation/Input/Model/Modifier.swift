//
//  Modifier.swift
//  Digit
//
//  Created by JSilver on 8/16/26.
//

import Foundation

public enum Modifier: String, Sendable, CaseIterable {
    case shift
    case control
    case option
    case command
    
    // MARK: - Property
    public var code: UInt32 {
        switch self {
        case .control:
            return 224
        
        case .shift:
            return 225
        
        case .option:
            return 226
        
        case .command:
            return 227
        }
    }
    
    // MARK: - Initializer
    // MARK: - Public
    // MARK: - Private
}

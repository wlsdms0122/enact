//
//  StopPoint.swift
//  Enact
//
//  Created by JSilver on 11/13/26.
//

import Foundation

// Where a run ends, the first time it reaches a statement of the scenario
// by its address: before the statement runs, or once it has.
public enum StopPoint: Sendable, Equatable {
    case before(String)
    case after(String)
    
    // MARK: - Property
    var address: String {
        switch self {
        case let .before(address), let .after(address):
            address
        }
    }
    
    var before: Bool {
        guard case .before = self else { return false }
        
        return true
    }
    
    // MARK: - Initializer
    // MARK: - Public
    // MARK: - Private
}

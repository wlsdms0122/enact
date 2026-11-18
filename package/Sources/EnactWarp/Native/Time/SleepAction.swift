//
//  SleepAction.swift
//  EnactWarp
//
//  Created by JSilver on 10/31/26.
//

import Foundation
import Warp

struct SleepAction: Warp.Effect {
    enum Parameters: Int, ParameterSet {
        case sec
        case because
        
        // MARK: - Property
        var declared: Parameter {
            switch self {
            case .sec:
                Parameter(name: "sec")
            
            case .because:
                Parameter(name: "because")
            }
        }
        
        // MARK: - Initializer
        // MARK: - Public
        // MARK: - Private
    }
    
    // MARK: - Property
    // MARK: - Initializer
    // MARK: - Public
    func run(_ invocation: Invocation<Self>) async throws -> Value {
        let seconds = try invocation.seconds(.sec)
        
        guard let because = invocation.string(.because),
            !because.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        else {
            throw StepFailure(.argumentRefused, "sleep says what it waits for in because")
        }
        
        try await Task.sleep(for: .seconds(seconds))
        
        return .null
    }
    
    // MARK: - Private
}

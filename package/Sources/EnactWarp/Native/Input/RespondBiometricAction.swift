//
//  RespondBiometricAction.swift
//  EnactWarp
//
//  Created by JSilver on 10/31/26.
//

import Digit
import Foundation
import Warp

struct RespondBiometricAction: EnactAction {
    enum Parameters: Int, ParameterSet {
        case outcome
        
        // MARK: - Property
        var declared: Parameter {
            switch self {
            case .outcome:
                Parameter(name: "outcome")
            }
        }
        
        // MARK: - Initializer
        // MARK: - Public
        // MARK: - Private
    }
    
    // MARK: - Property
    static let operations: Set<Digit.Operation> = [.respondBiometric]
    
    // MARK: - Initializer
    // MARK: - Public
    func act(_ invocation: Invocation<Self>, in environment: EnactEnvironment) async throws -> Warp.Value {
        try await environment.device.run(
            RespondBiometricOperator(try invocation.word(.outcome, in: EnactVocabulary.biometricOutcome))
        )
        
        return .null
    }
    
    // MARK: - Private
}

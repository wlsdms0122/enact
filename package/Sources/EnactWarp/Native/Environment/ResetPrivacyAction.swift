//
//  ResetPrivacyAction.swift
//  EnactWarp
//
//  Created by JSilver on 10/31/26.
//

import Digit
import Foundation
import Warp

struct ResetPrivacyAction: EnactAction {
    enum Parameters: Int, ParameterSet {
        case service
        
        // MARK: - Property
        var declared: Parameter {
            switch self {
            case .service:
                Parameter(name: "service")
            }
        }
        
        // MARK: - Initializer
        // MARK: - Public
        // MARK: - Private
    }
    
    // MARK: - Property
    static let operations: Set<Digit.Operation> = [.setPrivacy]
    
    // MARK: - Initializer
    // MARK: - Public
    func act(_ invocation: Invocation<Self>, in environment: EnactEnvironment) async throws -> Warp.Value {
        try await environment.device.run(
            try SetPrivacyOperator(
                decision: .reset,
                bundleID: nil,
                services: Set(try invocation.words(.service, in: EnactVocabulary.privacyService))
            )
        )
        
        return .null
    }
    
    // MARK: - Private
}

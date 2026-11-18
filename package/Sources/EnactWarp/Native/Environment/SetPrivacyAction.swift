//
//  SetPrivacyAction.swift
//  EnactWarp
//
//  Created by JSilver on 10/31/26.
//

import Digit
import Foundation
import Warp

struct SetPrivacyAction: EnactAction {
    enum Parameters: Int, ParameterSet {
        case action
        case service
        case bundleID
        
        // MARK: - Property
        var declared: Parameter {
            switch self {
            case .action:
                Parameter(name: "action")
            
            case .service:
                Parameter(name: "service")
            
            case .bundleID:
                Parameter(name: "bundle_id")
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
                decision: try invocation.word(.action, in: EnactVocabulary.privacyDecision),
                bundleID: try invocation.text(.bundleID),
                services: Set(try invocation.words(.service, in: EnactVocabulary.privacyService))
            )
        )
        
        return .null
    }
    
    // MARK: - Private
}

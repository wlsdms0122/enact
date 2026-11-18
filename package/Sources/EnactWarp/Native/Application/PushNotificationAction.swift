//
//  PushNotificationAction.swift
//  EnactWarp
//
//  Created by JSilver on 10/31/26.
//

import Digit
import Foundation
import Warp

struct PushNotificationAction: EnactAction {
    enum Parameters: Int, ParameterSet {
        case bundleID
        case payload
        
        // MARK: - Property
        var declared: Parameter {
            switch self {
            case .bundleID:
                Parameter(name: "bundle_id")
            
            case .payload:
                Parameter(name: "payload")
            }
        }
        
        // MARK: - Initializer
        // MARK: - Public
        // MARK: - Private
    }
    
    // MARK: - Property
    static let operations: Set<Digit.Operation> = [.pushNotification]
    
    // MARK: - Initializer
    // MARK: - Public
    func act(_ invocation: Invocation<Self>, in environment: EnactEnvironment) async throws -> Warp.Value {
        try await environment.device.run(
            PushNotificationOperator(bundleID: try invocation.text(.bundleID), payload: try invocation.json(.payload))
        )
        
        return .null
    }
    
    // MARK: - Private
}

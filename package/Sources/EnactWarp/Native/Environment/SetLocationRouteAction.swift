//
//  SetLocationRouteAction.swift
//  EnactWarp
//
//  Created by JSilver on 10/31/26.
//

import Digit
import Foundation
import Warp

struct SetLocationRouteAction: EnactAction {
    enum Parameters: Int, ParameterSet {
        case route
        
        // MARK: - Property
        var declared: Parameter {
            switch self {
            case .route:
                Parameter(name: "route")
            }
        }
        
        // MARK: - Initializer
        // MARK: - Public
        // MARK: - Private
    }
    
    // MARK: - Property
    static let operations: Set<Digit.Operation> = [.setLocation]
    
    // MARK: - Initializer
    // MARK: - Public
    func act(_ invocation: Invocation<Self>, in environment: EnactEnvironment) async throws -> Warp.Value {
        try await environment.device.run(SetLocationOperator(.scenario(try invocation.text(.route))))
        
        return .null
    }
    
    // MARK: - Private
}

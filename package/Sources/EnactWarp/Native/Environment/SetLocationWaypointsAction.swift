//
//  SetLocationWaypointsAction.swift
//  EnactWarp
//
//  Created by JSilver on 11/5/26.
//

import Digit
import Foundation
import Warp

struct SetLocationWaypointsAction: EnactAction {
    enum Parameters: Int, ParameterSet {
        case waypoints
        case speed
        
        // MARK: - Property
        var declared: Parameter {
            switch self {
            case .waypoints:
                Parameter(name: "waypoints")
            
            case .speed:
                Parameter(name: "speed")
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
        try await environment.device.run(
            try SetLocationOperator(.waypoints(try invocation.coordinates(.waypoints), speed: try invocation.optionalDouble(.speed)))
        )
        
        return .null
    }
    
    // MARK: - Private
}

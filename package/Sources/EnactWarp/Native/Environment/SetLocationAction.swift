//
//  SetLocationAction.swift
//  EnactWarp
//
//  Created by JSilver on 10/31/26.
//

import Digit
import Foundation
import Warp

struct SetLocationAction: EnactAction {
    enum Parameters: Int, ParameterSet {
        case lat
        case lon
        
        // MARK: - Property
        var declared: Parameter {
            switch self {
            case .lat:
                Parameter(name: "lat")
            
            case .lon:
                Parameter(name: "lon")
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
            SetLocationOperator(.fixed(try Coordinate(latitude: try invocation.double(.lat), longitude: try invocation.double(.lon))))
        )
        
        return .null
    }
    
    // MARK: - Private
}

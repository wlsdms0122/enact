//
//  SwipeBetweenAction.swift
//  EnactWarp
//
//  Created by JSilver on 10/31/26.
//

import Digit
import Foundation
import Warp

struct SwipeBetweenAction: EnactAction {
    enum Parameters: Int, ParameterSet {
        case from
        case to
        case duration
        
        // MARK: - Property
        var declared: Parameter {
            switch self {
            case .from:
                Parameter(name: "from")
            
            case .to:
                Parameter(name: "to")
            
            case .duration:
                Parameter(name: "duration")
            }
        }
        
        // MARK: - Initializer
        // MARK: - Public
        // MARK: - Private
    }
    
    // MARK: - Property
    static let operations: Set<Digit.Operation> = [.describeScreen, .swipe]
    
    // MARK: - Initializer
    // MARK: - Public
    func act(_ invocation: Invocation<Self>, in environment: EnactEnvironment) async throws -> Warp.Value {
        let screen = try await environment.device.run(DescribeScreenOperator())
        let stroke = try Stroke(
            start: screen.point(at: try invocation.fraction(.from)),
            end: screen.point(at: try invocation.fraction(.to)),
            duration: try invocation.double(.duration)
        )
        
        try await environment.device.run(SwipeOperator(stroke))
        
        return .null
    }
    
    // MARK: - Private
}

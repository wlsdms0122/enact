//
//  SwipeAction.swift
//  EnactWarp
//
//  Created by JSilver on 10/31/26.
//

import Digit
import Foundation
import Warp

struct SwipeAction: EnactAction {
    enum Parameters: Int, ParameterSet {
        case direction
        case duration
        
        // MARK: - Property
        var declared: Parameter {
            switch self {
            case .direction:
                Parameter(name: "direction")
            
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
        let direction = try invocation.word(.direction, in: EnactVocabulary.direction)
        
        try await environment.device.run(
            SwipeOperator(try direction.stroke(within: screen.frame, duration: try invocation.double(.duration)))
        )
        
        return .null
    }
    
    // MARK: - Private
}

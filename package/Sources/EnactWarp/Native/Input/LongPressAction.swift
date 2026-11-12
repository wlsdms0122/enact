//
//  LongPressAction.swift
//  EnactWarp
//
//  Created by JSilver on 10/31/26.
//

import Digit
import Foundation
import Warp

struct LongPressAction: EnactAction {
    enum Parameters: Int, ParameterSet {
        case on
        case at
        case duration
        
        // MARK: - Property
        var declared: Parameter {
            switch self {
            case .on:
                Parameter(name: "on")
            
            case .at:
                Parameter(name: "at")
            
            case .duration:
                Parameter(name: "duration")
            }
        }
        
        // MARK: - Initializer
        // MARK: - Public
        // MARK: - Private
    }
    
    // MARK: - Property
    static let operations: Set<Digit.Operation> = [.describeScreen, .longPress]
    
    // MARK: - Initializer
    // MARK: - Public
    func act(_ invocation: Invocation<Self>, in environment: EnactEnvironment) async throws -> Warp.Value {
        let snapshot = try invocation.snapshot(.on)
        let fraction = invocation[.at] == .null ? nil : try invocation.fraction(.at)
        let screen = try await environment.device.run(DescribeScreenOperator())
        
        try await environment.device.run(
            LongPressOperator(at: try snapshot.pressed(at: fraction, on: screen), duration: try invocation.double(.duration))
        )
        
        return .null
    }
    
    // MARK: - Private
}

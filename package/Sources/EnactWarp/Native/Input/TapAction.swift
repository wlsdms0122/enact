//
//  TapAction.swift
//  EnactWarp
//
//  Created by JSilver on 10/31/26.
//

import Digit
import Foundation
import Warp

struct TapAction: EnactAction {
    enum Parameters: Int, ParameterSet {
        case on
        case at
        
        // MARK: - Property
        var declared: Parameter {
            switch self {
            case .on:
                Parameter(name: "on")
            
            case .at:
                Parameter(name: "at")
            }
        }
        
        // MARK: - Initializer
        // MARK: - Public
        // MARK: - Private
    }
    
    // MARK: - Property
    static let operations: Set<Digit.Operation> = [.describeScreen, .describeUI, .tap]
    
    // MARK: - Initializer
    // MARK: - Public
    func act(_ invocation: Invocation<Self>, in environment: EnactEnvironment) async throws -> Warp.Value {
        let snapshot = try invocation.snapshot(.on)
        let fraction = invocation[.at] == .null ? nil : try invocation.fraction(.at)
        let point = try await snapshot.pressed(at: fraction, on: environment.device)
        
        try await environment.device.run(TapOperator(at: point))
        
        return .null
    }
    
    // MARK: - Private
}

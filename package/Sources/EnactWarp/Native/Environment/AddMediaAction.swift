//
//  AddMediaAction.swift
//  EnactWarp
//
//  Created by JSilver on 10/31/26.
//

import Digit
import Foundation
import Warp

struct AddMediaAction: EnactAction {
    enum Parameters: Int, ParameterSet {
        case paths
        
        // MARK: - Property
        var declared: Parameter {
            switch self {
            case .paths:
                Parameter(name: "paths")
            }
        }
        
        // MARK: - Initializer
        // MARK: - Public
        // MARK: - Private
    }
    
    // MARK: - Property
    static let operations: Set<Digit.Operation> = [.addMedia]
    
    // MARK: - Initializer
    // MARK: - Public
    func act(_ invocation: Invocation<Self>, in environment: EnactEnvironment) async throws -> Warp.Value {
        try await environment.device.run(try AddMediaOperator(paths: try invocation.texts(.paths)))
        
        return .null
    }
    
    // MARK: - Private
}

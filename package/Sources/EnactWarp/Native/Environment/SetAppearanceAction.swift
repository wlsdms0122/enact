//
//  SetAppearanceAction.swift
//  EnactWarp
//
//  Created by JSilver on 10/31/26.
//

import Digit
import Foundation
import Warp

struct SetAppearanceAction: EnactAction {
    enum Parameters: Int, ParameterSet {
        case value
        
        // MARK: - Property
        var declared: Parameter {
            switch self {
            case .value:
                Parameter(name: "value")
            }
        }
        
        // MARK: - Initializer
        // MARK: - Public
        // MARK: - Private
    }
    
    // MARK: - Property
    static let operations: Set<Digit.Operation> = [.setAppearance]
    
    // MARK: - Initializer
    // MARK: - Public
    func act(_ invocation: Invocation<Self>, in environment: EnactEnvironment) async throws -> Warp.Value {
        try await environment.device.run(SetAppearanceOperator(try invocation.word(.value, in: EnactVocabulary.appearance)))
        
        return .null
    }
    
    // MARK: - Private
}

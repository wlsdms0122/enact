//
//  PressKeyAction.swift
//  EnactWarp
//
//  Created by JSilver on 10/31/26.
//

import Digit
import Foundation
import Warp

struct PressKeyAction: EnactAction {
    enum Parameters: Int, ParameterSet {
        case key
        case modifiers
        
        // MARK: - Property
        var declared: Parameter {
            switch self {
            case .key:
                Parameter(name: "key")
            
            case .modifiers:
                Parameter(name: "modifiers")
            }
        }
        
        // MARK: - Initializer
        // MARK: - Public
        // MARK: - Private
    }
    
    // MARK: - Property
    static let operations: Set<Digit.Operation> = [.pressKey]
    
    // MARK: - Initializer
    // MARK: - Public
    func act(_ invocation: Invocation<Self>, in environment: EnactEnvironment) async throws -> Warp.Value {
        try await environment.device.run(
            PressKeyOperator(
                press: try invocation.keyPress(.key),
                modifiers: try invocation.words(.modifiers, in: EnactVocabulary.modifier)
            )
        )
        
        return .null
    }
    
    // MARK: - Private
}

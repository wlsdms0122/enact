//
//  TypeTextAction.swift
//  EnactWarp
//
//  Created by JSilver on 10/31/26.
//

import Digit
import Foundation
import Warp

struct TypeTextAction: EnactAction {
    enum Parameters: Int, ParameterSet {
        case text
        
        // MARK: - Property
        var declared: Parameter {
            switch self {
            case .text:
                Parameter(name: "text")
            }
        }
        
        // MARK: - Initializer
        // MARK: - Public
        // MARK: - Private
    }
    
    // MARK: - Property
    static let operations: Set<Digit.Operation> = [.typeText]
    
    // MARK: - Initializer
    // MARK: - Public
    func act(_ invocation: Invocation<Self>, in environment: EnactEnvironment) async throws -> Warp.Value {
        try await environment.device.run(TypeTextOperator(try invocation.text(.text)))
        
        return .null
    }
    
    // MARK: - Private
}

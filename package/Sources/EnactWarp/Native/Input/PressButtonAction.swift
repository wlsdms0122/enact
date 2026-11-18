//
//  PressButtonAction.swift
//  EnactWarp
//
//  Created by JSilver on 10/31/26.
//

import Digit
import Foundation
import Warp

struct PressButtonAction: EnactAction {
    enum Parameters: Int, ParameterSet {
        case button
        
        // MARK: - Property
        var declared: Parameter {
            switch self {
            case .button:
                Parameter(name: "button")
            }
        }
        
        // MARK: - Initializer
        // MARK: - Public
        // MARK: - Private
    }
    
    // MARK: - Property
    static let operations: Set<Digit.Operation> = [.pressButton]
    
    // MARK: - Initializer
    // MARK: - Public
    func act(_ invocation: Invocation<Self>, in environment: EnactEnvironment) async throws -> Warp.Value {
        try await environment.device.run(PressButtonOperator(try invocation.word(.button, in: EnactVocabulary.button)))
        
        return .null
    }
    
    // MARK: - Private
}

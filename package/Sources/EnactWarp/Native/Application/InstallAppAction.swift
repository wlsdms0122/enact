//
//  InstallAppAction.swift
//  EnactWarp
//
//  Created by JSilver on 10/31/26.
//

import Digit
import Foundation
import Warp

struct InstallAppAction: EnactAction {
    enum Parameters: Int, ParameterSet {
        case path
        
        // MARK: - Property
        var declared: Parameter {
            switch self {
            case .path:
                Parameter(name: "path")
            }
        }
        
        // MARK: - Initializer
        // MARK: - Public
        // MARK: - Private
    }
    
    // MARK: - Property
    static let operations: Set<Digit.Operation> = [.installApp]
    
    // MARK: - Initializer
    // MARK: - Public
    func act(_ invocation: Invocation<Self>, in environment: EnactEnvironment) async throws -> Warp.Value {
        try await environment.device.run(InstallAppOperator(path: try invocation.text(.path)))
        
        return .null
    }
    
    // MARK: - Private
}

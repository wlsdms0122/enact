//
//  UninstallAppAction.swift
//  EnactWarp
//
//  Created by JSilver on 10/31/26.
//

import Digit
import Foundation
import Warp

struct UninstallAppAction: EnactAction {
    enum Parameters: Int, ParameterSet {
        case bundleID
        
        // MARK: - Property
        var declared: Parameter {
            switch self {
            case .bundleID:
                Parameter(name: "bundle_id")
            }
        }
        
        // MARK: - Initializer
        // MARK: - Public
        // MARK: - Private
    }
    
    // MARK: - Property
    static let operations: Set<Digit.Operation> = [.uninstallApp]
    
    // MARK: - Initializer
    // MARK: - Public
    func act(_ invocation: Invocation<Self>, in environment: EnactEnvironment) async throws -> Warp.Value {
        try await environment.device.run(UninstallAppOperator(bundleID: try invocation.text(.bundleID)))
        
        return .null
    }
    
    // MARK: - Private
}

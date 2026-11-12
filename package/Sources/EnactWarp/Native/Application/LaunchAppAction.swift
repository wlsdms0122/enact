//
//  LaunchAppAction.swift
//  EnactWarp
//
//  Created by JSilver on 10/31/26.
//

import Digit
import Foundation
import Warp

struct LaunchAppAction: EnactAction {
    enum Parameters: Int, ParameterSet {
        case bundleID
        case args
        case locale
        case language
        
        // MARK: - Property
        var declared: Parameter {
            switch self {
            case .bundleID:
                Parameter(name: "bundle_id")
            
            case .args:
                Parameter(name: "args")
            
            case .locale:
                Parameter(name: "locale")
            
            case .language:
                Parameter(name: "language")
            }
        }
        
        // MARK: - Initializer
        // MARK: - Public
        // MARK: - Private
    }
    
    // MARK: - Property
    static let operations: Set<Digit.Operation> = [.launchApp]
    
    // MARK: - Initializer
    // MARK: - Public
    func act(_ invocation: Invocation<Self>, in environment: EnactEnvironment) async throws -> Warp.Value {
        _ = try await environment.device.run(
            LaunchAppOperator(
                bundleID: try invocation.text(.bundleID),
                arguments: try invocation.texts(.args),
                locale: invocation.string(.locale),
                language: invocation.string(.language)
            )
        )
        
        return .null
    }
    
    // MARK: - Private
}

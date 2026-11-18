//
//  AppStateAction.swift
//  EnactWarp
//
//  Created by JSilver on 11/10/26.
//

import Digit
import Foundation
import Warp

struct AppStateAction: EnactAction {
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
    static let operations: Set<Digit.Operation> = [.appState]
    
    // MARK: - Initializer
    // MARK: - Public
    func act(_ invocation: Invocation<Self>, in environment: EnactEnvironment) async throws -> Warp.Value {
        let state = try await environment.device.run(AppStateOperator(bundleID: try invocation.text(.bundleID)))
        
        return try EnactVocabulary.appState.value(of: state)
    }
    
    // MARK: - Private
}

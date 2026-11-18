//
//  OpenURLAction.swift
//  EnactWarp
//
//  Created by JSilver on 10/31/26.
//

import Digit
import Foundation
import Warp

struct OpenURLAction: EnactAction {
    enum Parameters: Int, ParameterSet {
        case url
        
        // MARK: - Property
        var declared: Parameter {
            switch self {
            case .url:
                Parameter(name: "url")
            }
        }
        
        // MARK: - Initializer
        // MARK: - Public
        // MARK: - Private
    }
    
    // MARK: - Property
    static let operations: Set<Digit.Operation> = [.openURL]
    
    // MARK: - Initializer
    // MARK: - Public
    func act(_ invocation: Invocation<Self>, in environment: EnactEnvironment) async throws -> Warp.Value {
        let written = try invocation.text(.url)
        
        guard !written.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty, let url = URL(string: written) else {
            throw StepFailure(.argumentRefused, "url: '\(written)' is not a URL")
        }
        
        try await environment.device.run(OpenURLOperator(url))
        
        return .null
    }
    
    // MARK: - Private
}

//
//  AddCertificateAction.swift
//  EnactWarp
//
//  Created by JSilver on 11/5/26.
//

import Digit
import Foundation
import Warp

struct AddCertificateAction: EnactAction {
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
    static let operations: Set<Digit.Operation> = [.addCertificate]
    
    // MARK: - Initializer
    // MARK: - Public
    func act(_ invocation: Invocation<Self>, in environment: EnactEnvironment) async throws -> Warp.Value {
        try await environment.device.run(AddCertificateOperator(path: try invocation.text(.path), root: false))
        
        return .null
    }
    
    // MARK: - Private
}

//
//  ClearLocationAction.swift
//  EnactWarp
//
//  Created by JSilver on 10/31/26.
//

import Digit
import Foundation
import Warp

struct ClearLocationAction: EnactAction {
    typealias Parameters = NoParameters
    
    // MARK: - Property
    static let operations: Set<Digit.Operation> = [.setLocation]
    
    // MARK: - Initializer
    // MARK: - Public
    func act(_ invocation: Invocation<Self>, in environment: EnactEnvironment) async throws -> Warp.Value {
        try await environment.device.run(SetLocationOperator(.clear))
        
        return .null
    }
    
    // MARK: - Private
}

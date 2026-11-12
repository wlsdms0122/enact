//
//  ResetKeychainAction.swift
//  EnactWarp
//
//  Created by JSilver on 11/5/26.
//

import Digit
import Foundation
import Warp

struct ResetKeychainAction: EnactAction {
    typealias Parameters = NoParameters
    
    // MARK: - Property
    static let operations: Set<Digit.Operation> = [.resetKeychain]
    
    // MARK: - Initializer
    // MARK: - Public
    func act(_ invocation: Invocation<Self>, in environment: EnactEnvironment) async throws -> Warp.Value {
        try await environment.device.run(ResetKeychainOperator())
        
        return .null
    }
    
    // MARK: - Private
}

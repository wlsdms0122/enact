//
//  ConnectHardwareKeyboardAction.swift
//  EnactWarp
//
//  Created by JSilver on 11/9/26.
//

import Digit
import Foundation
import Warp

struct ConnectHardwareKeyboardAction: EnactAction {
    typealias Parameters = NoParameters
    
    // MARK: - Property
    static let operations: Set<Digit.Operation> = [.setHardwareKeyboard]
    
    // MARK: - Initializer
    // MARK: - Public
    func act(_ invocation: Invocation<Self>, in environment: EnactEnvironment) async throws -> Warp.Value {
        try await environment.device.run(SetHardwareKeyboardOperator(.connected))
        
        return .null
    }
    
    // MARK: - Private
}

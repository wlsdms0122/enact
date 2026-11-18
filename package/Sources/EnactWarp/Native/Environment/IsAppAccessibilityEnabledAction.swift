//
//  IsAppAccessibilityEnabledAction.swift
//  EnactWarp
//
//  Created by JSilver on 11/11/26.
//

import Digit
import Foundation
import Warp

struct IsAppAccessibilityEnabledAction: EnactAction {
    typealias Parameters = NoParameters
    
    // MARK: - Property
    static let operations: Set<Digit.Operation> = [.appAccessibility]
    
    // MARK: - Initializer
    // MARK: - Public
    func act(_ invocation: Invocation<Self>, in environment: EnactEnvironment) async throws -> Warp.Value {
        .bool(try await environment.device.run(AppAccessibilityOperator()) == .enabled)
    }
    
    // MARK: - Private
}

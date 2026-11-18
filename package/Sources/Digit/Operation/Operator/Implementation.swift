//
//  Implementation.swift
//  Digit
//
//  Created by JSilver on 8/16/26.
//

import Foundation

struct Implementation {
    // MARK: - Property
    let operation: Operation
    let type: ObjectIdentifier
    let body: Any
    
    // MARK: - Initializer
    // MARK: - Public
    static func perform<O: Operator>(
        _ body: @escaping (O) async throws -> O.Result
    ) -> Implementation {
        Implementation(operation: O.operation, type: ObjectIdentifier(O.self), body: body)
    }
    
    // MARK: - Private
}

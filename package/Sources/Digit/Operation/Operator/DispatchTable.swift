//
//  DispatchTable.swift
//  Digit
//
//  Created by JSilver on 8/16/26.
//

import Foundation

struct DispatchTable {
    // MARK: - Property
    let operations: Set<Operation>
    
    private let byType: [ObjectIdentifier: Any]
    
    // MARK: - Initializer
    init(_ implementations: [Implementation]) {
        byType = Dictionary(uniqueKeysWithValues: implementations.map { ($0.type, $0.body) })
        operations = Set(
            Dictionary(uniqueKeysWithValues: implementations.map { ($0.operation, $0.type) }).keys
        )
    }
    
    // MARK: - Public
    // Every operation a device starts passes here, and a cancelled task
    // starts none.
    func body<O: Operator>(for _: O.Type) -> ((O) async throws -> O.Result)? {
        guard let body = byType[ObjectIdentifier(O.self)] as? (O) async throws -> O.Result else { return nil }
        
        return { operation in
            try Task.checkCancellation()
            
            return try await body(operation)
        }
    }
    
    // MARK: - Private
}

//
//  RecordLogAction.swift
//  EnactWarp
//
//  Created by JSilver on 11/11/26.
//

import Digit
import Foundation
import Warp

// Writes the device's log stream while its body runs, as a recording span.
// Logs stream beside a video and beside one another, so a record_log inside a
// record or a record_log runs.
struct RecordLogAction: EnactAction {
    enum Parameters: Int, ParameterSet {
        case name
        case predicate
        case body
        
        // MARK: - Property
        var declared: Parameter {
            switch self {
            case .name:
                Parameter(name: "name")
            
            case .predicate:
                Parameter(name: "predicate")
            
            case .body:
                Parameter(name: "body")
            }
        }
        
        // MARK: - Initializer
        // MARK: - Public
        // MARK: - Private
    }
    
    // MARK: - Property
    static let operations: Set<Digit.Operation> = [.recordLog]
    
    // MARK: - Initializer
    // MARK: - Public
    func act(_ invocation: Invocation<Self>, in environment: EnactEnvironment) async throws -> Warp.Value {
        guard case let .procedure(body) = invocation[.body] else {
            throw RunRefused("'\(invocation.selector)' was handed \(invocation[.body]) for body, where a procedure is declared")
        }
        
        let predicate = try invocation.string(.predicate)
        
        return try await RecordingSpan(name: invocation.string(.name) ?? "log", ext: "log").record(in: environment) { path in
            try await environment.device.recordLog(to: path, matching: predicate) {
                try await invocation.call(body, piece: "body")
            }
        }
    }
    
    // MARK: - Private
}

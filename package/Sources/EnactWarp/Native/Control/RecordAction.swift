//
//  RecordAction.swift
//  EnactWarp
//
//  Created by JSilver on 10/31/26.
//

import Digit
import Foundation
import Warp

// Records video of the device while its body runs, as a recording span. A device
// records one video at a time, so a record inside a record is refused here.
struct RecordAction: EnactAction {
    enum Parameters: Int, ParameterSet {
        case name
        case body
        
        // MARK: - Property
        var declared: Parameter {
            switch self {
            case .name:
                Parameter(name: "name")
            
            case .body:
                Parameter(name: "body")
            }
        }
        
        // MARK: - Initializer
        // MARK: - Public
        // MARK: - Private
    }
    
    // MARK: - Property
    static let operations: Set<Digit.Operation> = [.recordVideo]
    
    // MARK: - Initializer
    // MARK: - Public
    func act(_ invocation: Invocation<Self>, in environment: EnactEnvironment) async throws -> Warp.Value {
        guard case let .procedure(body) = invocation[.body] else {
            throw RunRefused("'\(invocation.selector)' was handed \(invocation[.body]) for body, where a procedure is declared")
        }
        
        return try await RecordingSpan(name: invocation.string(.name) ?? "video", ext: "mp4").record(in: environment) { path in
            try await environment.device.recordVideo(to: path) {
                try await invocation.call(body, piece: "body")
            }
        }
    }
    
    // MARK: - Private
}

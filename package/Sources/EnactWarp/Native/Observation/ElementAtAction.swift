//
//  ElementAtAction.swift
//  EnactWarp
//
//  Created by JSilver on 11/9/26.
//

import Digit
import Foundation
import Warp

// Reads the element the screen hit-tests at a point, which a press there
// lands on, or none where nothing answers. It stands in no look, so its index
// path is empty.
struct ElementAtAction: EnactAction {
    enum Parameters: Int, ParameterSet {
        case at
        
        // MARK: - Property
        var declared: Parameter {
            switch self {
            case .at:
                Parameter(name: "at")
            }
        }
        
        // MARK: - Initializer
        // MARK: - Public
        // MARK: - Private
    }
    
    // MARK: - Property
    static let operations: Set<Digit.Operation> = [.describeScreen, .describeUI]
    
    // MARK: - Initializer
    // MARK: - Public
    func act(_ invocation: Invocation<Self>, in environment: EnactEnvironment) async throws -> Warp.Value {
        let screen = try await environment.device.run(DescribeScreenOperator())
        let hit = try await environment.device.run(DescribeUIOperator(at: screen.point(at: try invocation.fraction(.at))))
        
        guard let element = hit.first else { return .null }
        
        return try Warp.Value(Snapshot(element, at: []))
    }
    
    // MARK: - Private
}

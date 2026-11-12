//
//  TapPointAction.swift
//  EnactWarp
//
//  Created by JSilver on 11/1/26.
//

import Digit
import Foundation
import Warp

// Taps a point of the screen, for what the screen shows but no look can
// name: a map, a canvas, a web page that says nothing of itself.
struct TapPointAction: EnactAction {
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
    static let operations: Set<Digit.Operation> = [.describeScreen, .tap]
    
    // MARK: - Initializer
    // MARK: - Public
    func act(_ invocation: Invocation<Self>, in environment: EnactEnvironment) async throws -> Warp.Value {
        let screen = try await environment.device.run(DescribeScreenOperator())
        
        try await environment.device.run(TapOperator(at: screen.point(at: try invocation.fraction(.at))))
        
        return .null
    }
    
    // MARK: - Private
}

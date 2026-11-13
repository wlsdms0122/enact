//
//  DragOnAction.swift
//  EnactWarp
//
//  Created by JSilver on 11/13/26.
//

import Digit
import Foundation
import Warp

// Drags inside a snapshot so its content moves in direction, across the part
// of it the screen shows, and lets go at rest: a list moves as far as the
// stroke and stops, where a swipe flings it on.
struct DragOnAction: EnactAction {
    enum Parameters: Int, ParameterSet {
        case on
        case direction
        case duration
        
        // MARK: - Property
        var declared: Parameter {
            switch self {
            case .on:
                Parameter(name: "on")
            
            case .direction:
                Parameter(name: "direction")
            
            case .duration:
                Parameter(name: "duration")
            }
        }
        
        // MARK: - Initializer
        // MARK: - Public
        // MARK: - Private
    }
    
    // MARK: - Property
    static let operations: Set<Digit.Operation> = [.describeScreen, .drag]
    
    // MARK: - Initializer
    // MARK: - Public
    func act(_ invocation: Invocation<Self>, in environment: EnactEnvironment) async throws -> Warp.Value {
        let snapshot = try invocation.snapshot(.on)
        let direction = try invocation.word(.direction, in: EnactVocabulary.direction)
        let screen = try await environment.device.run(DescribeScreenOperator())
        
        guard let shown = screen.visible(snapshot.frame) else {
            throw StepFailure(.referenceUnfit, "\(snapshot.named) is off the screen, so there is nothing of it to drag")
        }
        
        try await environment.device.run(
            DragOperator(try direction.stroke(within: shown, duration: try invocation.double(.duration)))
        )
        
        return .null
    }
    
    // MARK: - Private
}

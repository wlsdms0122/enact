//
//  FullyVisibleQuery.swift
//  EnactWarp
//
//  Created by JSilver on 11/13/26.
//

import Digit
import Foundation
import Warp

// The snapshots a container shows whole: each frame inside the part of the
// container the screen shows. One cut by the container's edge, or by the
// screen's, is left out.
struct FullyVisibleQuery: Warp.Query {
    enum Parameters: Int, ParameterSet {
        case elements
        case container
        case screen
        
        // MARK: - Property
        var declared: Parameter {
            switch self {
            case .elements:
                Parameter(name: "elements")
            
            case .container:
                Parameter(name: "in")
            
            case .screen:
                Parameter(name: "screen")
            }
        }
        
        // MARK: - Initializer
        // MARK: - Public
        // MARK: - Private
    }
    
    // MARK: - Property
    // MARK: - Initializer
    // MARK: - Public
    func evaluate(_ question: Question<Self>) async throws -> Warp.Value {
        let container = try Snapshot(question[.container])
        let screen = try Screen(question[.screen])
        let elements = try [Snapshot](question[.elements])
        
        guard let shown = screen.visible(container.frame) else { return .array([]) }
        
        return .array(try elements.filter { snapshot in shown.contains(snapshot.frame) }.map(Warp.Value.init))
    }
    
    // MARK: - Private
}

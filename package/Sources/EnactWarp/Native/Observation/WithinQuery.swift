//
//  WithinQuery.swift
//  EnactWarp
//
//  Created by JSilver on 10/31/26.
//

import Digit
import Foundation
import Warp

// The snapshots that sit inside a container, each one the container holds at
// any depth, as the tree of one look says.
struct WithinQuery: Warp.Query {
    enum Parameters: Int, ParameterSet {
        case elements
        case container
        
        // MARK: - Property
        var declared: Parameter {
            switch self {
            case .elements:
                Parameter(name: "elements")
            
            case .container:
                Parameter(name: "in")
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
        // A container standing in no look, as one read at a point, holds
        // nothing a look's tree says.
        let inside = try [Snapshot](question[.elements]).filter { snapshot in
            !container.indexPath.isEmpty
                && snapshot.indexPath.count > container.indexPath.count
                && snapshot.indexPath.starts(with: container.indexPath)
        }
        
        return .array(try inside.map(Warp.Value.init))
    }
    
    // MARK: - Private
}

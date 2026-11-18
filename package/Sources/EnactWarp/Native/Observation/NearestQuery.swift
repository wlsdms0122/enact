//
//  NearestQuery.swift
//  EnactWarp
//
//  Created by JSilver on 10/31/26.
//

import Digit
import Foundation
import Warp

// The snapshots ordered by how far the middle of each is from a point of the
// screen, given as fractions of its width and height, the nearest first.
struct NearestQuery: Warp.Query {
    enum Parameters: Int, ParameterSet {
        case elements
        case to
        case screen
        
        // MARK: - Property
        var declared: Parameter {
            switch self {
            case .elements:
                Parameter(name: "elements")
            
            case .to:
                Parameter(name: "to")
            
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
        let screen = try Screen(question[.screen])
        let aim = screen.point(at: try fraction(question[.to]))
        let ordered = try [Snapshot](question[.elements])
            .enumerated()
            .sorted { one, other in
                let (near, far) = (distance(of: one.element, to: aim), distance(of: other.element, to: aim))
                
                return near == far ? one.offset < other.offset : near < far
            }
            .map(\.element)
        
        return .array(try ordered.map(Warp.Value.init))
    }
    
    // MARK: - Private
    private func fraction(_ value: Warp.Value) throws -> Point {
        guard case let .struct(held) = value,
            case let .double(x) = held["x"],
            case let .double(y) = held["y"]
        else {
            throw RunRefused("\(value) is not an \(EnactVocabulary.pointType)")
        }
        
        guard (0...1).contains(x), (0...1).contains(y) else {
            throw StepFailure(.argumentRefused, "to is { x: \(x), y: \(y) }, and a point is fractions from 0 to 1")
        }
        
        return Point(x: x, y: y)
    }
    
    private func distance(of snapshot: Snapshot, to point: Point) -> Double {
        let middle = snapshot.frame.center
        
        return (middle.x - point.x) * (middle.x - point.x) + (middle.y - point.y) * (middle.y - point.y)
    }
}

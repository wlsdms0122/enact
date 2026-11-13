//
//  Direction.swift
//  EnactWarp
//
//  Created by JSilver on 10/31/26.
//

import Digit
import Foundation

// Which way a swipe moves the content: up drags from low to high in what it
// crosses, the screen or an element.
package enum Direction: String, Sendable, CaseIterable {
    case up
    case down
    case left
    case right
    
    // MARK: - Property
    // How far a stroke reaches, as a fraction of what it crosses.
    static let reach = far - near
    
    private static let (near, middle, far) = (0.2, 0.5, 0.8)
    
    // MARK: - Initializer
    // MARK: - Public
    // The stroke inside a frame, between a fifth and four fifths of the way
    // across it.
    func stroke(within frame: Element.Frame, duration: Double) throws -> Stroke {
        let (start, end) = ends
        
        return try Stroke(start: frame.point(at: start), end: frame.point(at: end), duration: duration)
    }
    
    // Where a stroke that begins at a point ends, both as fractions of what it
    // crosses: as far on as a stroke reaches, and no further than the edge.
    package func end(from start: Point) -> Point {
        switch self {
        case .up:
            Point(x: start.x, y: max(start.y - Self.reach, 0))
        
        case .down:
            Point(x: start.x, y: min(start.y + Self.reach, 1))
        
        case .left:
            Point(x: max(start.x - Self.reach, 0), y: start.y)
        
        case .right:
            Point(x: min(start.x + Self.reach, 1), y: start.y)
        }
    }
    
    // MARK: - Private
    // Where the stroke starts and ends, as fractions of what it crosses.
    private var ends: (start: Point, end: Point) {
        let (near, middle, far) = (Self.near, Self.middle, Self.far)
        
        return switch self {
        case .up:
            (Point(x: middle, y: far), Point(x: middle, y: near))
        
        case .down:
            (Point(x: middle, y: near), Point(x: middle, y: far))
        
        case .left:
            (Point(x: far, y: middle), Point(x: near, y: middle))
        
        case .right:
            (Point(x: near, y: middle), Point(x: far, y: middle))
        }
    }
}

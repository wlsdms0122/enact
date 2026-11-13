//
//  DirectionTests.swift
//  EnactWarpTests
//
//  Created by JSilver on 10/31/26.
//

import Foundation
import Testing
@testable import Digit
@testable import EnactWarp

@Suite("A swipe's direction is the way the content moves")
struct DirectionTests {
    // MARK: - Property
    // MARK: - Initializer
    // MARK: - Test
    @Test("each direction strokes between a fifth and four fifths of the frame it crosses", arguments: [
        (Direction.up, (50.0, 160.0), (50.0, 40.0)),
        (Direction.down, (50.0, 40.0), (50.0, 160.0)),
        (Direction.left, (80.0, 100.0), (20.0, 100.0)),
        (Direction.right, (20.0, 100.0), (80.0, 100.0))
    ])
    func eachDirectionStrokes(_ sut: Direction, _ start: (Double, Double), _ end: (Double, Double)) throws {
        // Given
        let screen = try Screen(width: 100, height: 200)
        
        // When
        let stroke = try sut.stroke(within: screen.frame, duration: 0.2)
        
        // Then
        #expect(stroke.start.x == start.0)
        #expect(stroke.start.y == start.1)
        #expect(stroke.end.x == end.0)
        #expect(stroke.end.y == end.1)
    }
    
    @Test("inside an element, the stroke stays within its frame")
    func aStrokeStaysWithinAnElement() throws {
        // Given
        let frame = Element.Frame(x: 100, y: 200, width: 80, height: 40)
        
        // When
        let stroke = try Direction.up.stroke(within: frame, duration: 0.2)
        
        // Then
        #expect((stroke.start.x, stroke.start.y) == (140, 232))
        #expect((stroke.end.x, stroke.end.y) == (140, 208))
    }
    
    @Test("a stroke that begins at a point ends as far on as a stroke reaches, and no further than the edge", arguments: [
        (Direction.up, (0.5, 0.9), (0.5, 0.3)),
        (Direction.up, (0.5, 0.4), (0.5, 0.0)),
        (Direction.down, (0.5, 0.5), (0.5, 1.0)),
        (Direction.left, (0.7, 0.2), (0.1, 0.2)),
        (Direction.right, (0.7, 0.2), (1.0, 0.2))
    ])
    func aStrokeEndsFromWhereItBegins(_ sut: Direction, _ start: (Double, Double), _ end: (Double, Double)) {
        // Given
        let start = Point(x: start.0, y: start.1)
        
        // When
        let reached = sut.end(from: start)
        
        // Then
        #expect(abs(reached.x - end.0) < 1e-9)
        #expect(abs(reached.y - end.1) < 1e-9)
    }
    
    // MARK: - Private
}

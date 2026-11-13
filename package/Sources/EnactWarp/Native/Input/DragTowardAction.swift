//
//  DragTowardAction.swift
//  EnactWarp
//
//  Created by JSilver on 11/13/26.
//

import Digit
import Foundation
import Warp

// Drags inside a snapshot so an element in it moves toward the middle of the
// part the screen shows, along each way the element is not already inside
// that part and could be, and lets go at rest. One stroke goes no further than
// a drag_on's, so an element far off comes closer a stroke at a time, and a
// move too short to be read as a drag is not made.
struct DragTowardAction: EnactAction {
    enum Parameters: Int, ParameterSet {
        case on
        case element
        
        // MARK: - Property
        var declared: Parameter {
            switch self {
            case .on:
                Parameter(name: "on")
            
            case .element:
                Parameter(name: "element")
            }
        }
        
        // MARK: - Initializer
        // MARK: - Public
        // MARK: - Private
    }
    
    // MARK: - Property
    static let operations: Set<Digit.Operation> = [.describeScreen, .drag]
    
    // A scroll view follows a finger only once it has moved about this far,
    // and a shorter stroke can read as a press.
    private static let hysteresis = 10.0
    private static let duration = 0.2
    
    // MARK: - Initializer
    // MARK: - Public
    func act(_ invocation: Invocation<Self>, in environment: EnactEnvironment) async throws -> Warp.Value {
        let container = try invocation.snapshot(.on)
        let element = try invocation.snapshot(.element)
        let screen = try await environment.device.run(DescribeScreenOperator())
        
        guard let shown = screen.visible(container.frame) else {
            throw StepFailure(.referenceUnfit, "\(container.named) is off the screen, so there is nothing of it to drag")
        }
        
        let move = Point(
            x: shift(element.frame.x, element.frame.width, into: shown.x, shown.width),
            y: shift(element.frame.y, element.frame.height, into: shown.y, shown.height)
        )
        
        guard hypot(move.x, move.y) >= Self.hysteresis else { return .null }
        
        let middle = shown.center
        let stroke = try Stroke(
            start: Point(x: (middle.x - move.x / 2).rounded(), y: (middle.y - move.y / 2).rounded()),
            end: Point(x: (middle.x + move.x / 2).rounded(), y: (middle.y + move.y / 2).rounded()),
            duration: Self.duration
        )
        
        try await environment.device.run(DragOperator(stroke))
        
        return .null
    }
    
    // MARK: - Private
    // How far the content moves along one way: none where the element already
    // lies inside the part shown, or could not, being as long as it; else its
    // middle to the part's, as far as a stroke reaches.
    private func shift(_ start: Double, _ length: Double, into shownStart: Double, _ shownLength: Double) -> Double {
        guard length < shownLength, start < shownStart || start + length > shownStart + shownLength else { return 0 }
        
        let reach = shownLength * Direction.reach
        
        return min(max((shownStart + shownLength / 2) - (start + length / 2), -reach), reach)
    }
}

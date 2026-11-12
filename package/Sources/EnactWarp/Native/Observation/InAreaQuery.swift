//
//  InAreaQuery.swift
//  EnactWarp
//
//  Created by JSilver on 10/31/26.
//

import Digit
import Foundation
import Warp

// The snapshots whose frame meets an area of the screen, given as fractions
// of its width and height.
struct InAreaQuery: Warp.Query {
    enum Parameters: Int, ParameterSet {
        case elements
        case area
        case screen
        
        // MARK: - Property
        var declared: Parameter {
            switch self {
            case .elements:
                Parameter(name: "elements")
            
            case .area:
                Parameter(name: "area")
            
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
        let area = try zone(question[.area], on: screen)
        let met = try [Snapshot](question[.elements]).filter { snapshot in
            let frame = snapshot.frame
            
            return frame.x < area.x + area.width && area.x < frame.x + frame.width
                && frame.y < area.y + area.height && area.y < frame.y + frame.height
        }
        
        return .array(try met.map(Warp.Value.init))
    }
    
    // MARK: - Private
    private func zone(_ value: Warp.Value, on screen: Screen) throws -> Element.Frame {
        guard case let .struct(held) = value,
            case let .double(x) = held["x"],
            case let .double(y) = held["y"],
            case let .double(width) = held["width"],
            case let .double(height) = held["height"]
        else {
            throw RunRefused("\(value) is not an \(EnactVocabulary.frameType)")
        }
        
        guard [x, y, width, height].allSatisfy({ number in (0...1).contains(number) }), width > 0, height > 0 else {
            throw StepFailure(
                .argumentRefused,
                "area is { x: \(x), y: \(y), width: \(width), height: \(height) }, and an area is fractions of the screen, "
                    + "with a width and a height"
            )
        }
        
        return Element.Frame(x: x * screen.width, y: y * screen.height, width: width * screen.width, height: height * screen.height)
    }
}

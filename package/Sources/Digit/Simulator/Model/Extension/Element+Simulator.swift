//
//  Element+Simulator.swift
//  Digit
//
//  Created by JSilver on 8/16/26.
//

import FBSimulatorAX
import Foundation

extension Element {
    init(_ element: AccessibilityDocumentElement, springBoardFrames: SpringBoardFrames? = nil) throws {
        guard let frame = element.frame ?? nil,
            let x = frame.x,
            let y = frame.y,
            let width = frame.width,
            let height = frame.height
        else {
            throw DigitError.unreadableOutput(
                of: "accessibility tree",
                reason: "a node is missing its frame"
            )
        }
        
        let read = Frame(x: x, y: y, width: width, height: height)
        
        self.init(
            id: element.identifier ?? nil,
            label: (element.label ?? nil) ?? (element.title ?? nil),
            value: (element.value ?? nil).flatMap(Self.text),
            role: Role(traits: (element.traits ?? nil) ?? [], type: element.type ?? nil),
            frame: springBoardFrames?.frame(read, of: element) ?? read,
            enabled: (element.enabled ?? nil) ?? true,
            actions: (element.customActions ?? nil) ?? [],
            children: try (element.children ?? []).map { child in try Element(child, springBoardFrames: springBoardFrames) }
        )
    }
    
    private static func text(_ value: AccessibilityAttributeValue) -> String? {
        guard case let .string(text) = value else { return nil }
        
        return text
    }
}

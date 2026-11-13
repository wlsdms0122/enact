//
//  Look.swift
//  EnactWarp
//
//  Created by JSilver on 11/13/26.
//

import Digit
import Foundation
import Warp

// One read of the screen, the `Enact.Screen` a look returns: its size and
// every element on it in reading order, each before the elements inside it,
// with where it sits in the tree. Written down, it is the screen a failure
// left and the screen a judgment is evaluated against.
package struct Look: Sendable, Equatable, Codable {
    // MARK: - Property
    package let width: Double
    package let height: Double
    package let elements: [Snapshot]
    
    package var value: Warp.Value {
        get throws {
            try .holding(
                [
                    (name: "width", value: .double(width)),
                    (name: "height", value: .double(height)),
                    (name: "elements", value: .array(try elements.map(Warp.Value.init)))
                ],
                named: EnactVocabulary.screenType
            )
        }
    }
    
    // MARK: - Initializer
    package init(screen: Screen, tree: [Element]) {
        self.width = screen.width
        self.height = screen.height
        self.elements = Self.flattened(tree, under: [])
    }
    
    // MARK: - Public
    // MARK: - Private
    private static func flattened(_ elements: [Element], under path: [Int]) -> [Snapshot] {
        elements.enumerated().flatMap { index, element in
            [Snapshot(element, at: path + [index])] + flattened(element.children, under: path + [index])
        }
    }
}

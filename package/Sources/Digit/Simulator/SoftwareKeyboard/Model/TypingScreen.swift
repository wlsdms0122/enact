//
//  TypingScreen.swift
//  Digit
//
//  Created by JSilver on 11/10/26.
//

import FBSimulatorAX
import Foundation

// One read of the screen as typing sees it: the keys the software keyboard shows, and
// the text of every field, which the field typed into changes.
struct TypingScreen {
    // MARK: - Property
    let keyplane: Keyplane
    // The values of the fields and secure fields, in the order the tree has them.
    let fieldValues: [String?]

    // MARK: - Initializer
    init(_ tree: [AccessibilityDocumentElement]) throws {
        let elements = try tree.map { element in try Element(element) }.flatMap(Self.flattened)

        self.keyplane = Keyplane(elements.filter { element in element.role == .key })
        self.fieldValues = elements
            .filter { element in element.role == .field || element.role == .secureField }
            .map(\.value)
    }

    // MARK: - Public
    // MARK: - Private
    private static func flattened(_ element: Element) -> [Element] {
        [element] + element.children.flatMap(flattened)
    }
}

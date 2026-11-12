//
//  ElementCatch.swift
//  EnactCLI
//
//  Created by JSilver on 11/10/26.
//

import Digit
import Enact
import EnactWarp
import Foundation

// What a draft catches an element by: its label, its identifier, or its role
// and the text it shows.
enum ElementCatch: Equatable {
    case label(String)
    case id(String)
    case shown(Role, String)
    
    // MARK: - Property
    // MARK: - Initializer
    // The catches an element shows, label first, then identifier, then role and
    // text. Empty for an element that shows nothing to catch it by.
    static func catches(of element: ObservedElement) -> [ElementCatch] {
        var catches: [ElementCatch] = []
        
        if let label = element.snapshot.label, !label.isEmpty { catches.append(.label(label)) }
        if let id = element.snapshot.id, !id.isEmpty { catches.append(.id(id)) }
        if !element.text.isEmpty { catches.append(.shown(element.snapshot.role, element.text)) }
        
        return catches
    }
    
    // MARK: - Public
    func holds(of element: ObservedElement) -> Bool {
        switch self {
        case let .label(label):
            element.snapshot.label == label
        
        case let .id(id):
            element.snapshot.id == id
        
        case let .shown(role, text):
            element.snapshot.role == role && element.text == text
        }
    }
    
    // The `where` a `wait_for` is handed, over a snapshot of a look.
    var `where`: DraftNode {
        let one = "one"
        
        switch self {
        case let .label(label):
            return .closure(parameter: one, type: "Enact.Snapshot", result: .is(.ref("\(one).label"), .quoted(label)))
        
        case let .id(id):
            return .closure(parameter: one, type: "Enact.Snapshot", result: .is(.ref("\(one).id"), .quoted(id)))
        
        case let .shown(role, text):
            // A case literal is written where its enum is read, so the role is
            // bound to a typed name before it is compared.
            return .closure(
                parameter: one,
                type: "Enact.Snapshot",
                body: [.let("role", type: "Enact.Role", value: .enumCase(EnactVocabulary.role.caseName(of: role)))],
                result: .allOf([
                    .is(.ref("\(one).role"), .ref("role")),
                    .is(.call("displayed_text", [DraftNode.Entry("of", .ref(one))]), .quoted(text))
                ])
            )
        }
    }
    
    // MARK: - Private
}

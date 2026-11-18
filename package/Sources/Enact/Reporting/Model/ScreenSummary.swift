//
//  ScreenSummary.swift
//  Enact
//
//  Created by JSilver on 11/13/26.
//

import Digit
import EnactWarp
import Foundation

// What a screen showed at a glance: the text of its headings, buttons and
// fields in reading order, each its label, or its value where the label is
// empty.
public struct ScreenSummary: Sendable, Encodable, Equatable {
    // MARK: - Property
    public let headings: [String]
    public let buttons: [String]
    public let fields: [String]
    
    // MARK: - Initializer
    init(_ look: Look) {
        func texts(of roles: Set<Role>) -> [String] {
            look.elements.compactMap { snapshot in
                guard roles.contains(snapshot.role) else { return nil }
                
                let text = snapshot.label.flatMap { label in label.isEmpty ? nil : label } ?? snapshot.value
                
                return text.flatMap { text in text.isEmpty ? nil : text }
            }
        }
        
        self.headings = texts(of: [.heading])
        self.buttons = texts(of: [.button])
        self.fields = texts(of: [.field, .secureField])
    }
    
    // MARK: - Public
    // MARK: - Private
}

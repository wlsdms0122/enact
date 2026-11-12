//
//  ObservedElement.swift
//  Enact
//
//  Created by JSilver on 11/10/26.
//

import EnactWarp
import Foundation

// An element as a look saw it, with the text `displayed_text` reads of it.
package struct ObservedElement: Sendable, Equatable {
    // MARK: - Property
    package let snapshot: Snapshot
    package let text: String
    
    // MARK: - Initializer
    package init(_ snapshot: Snapshot, text: String) {
        self.snapshot = snapshot
        self.text = text
    }
    
    // MARK: - Public
    // MARK: - Private
}

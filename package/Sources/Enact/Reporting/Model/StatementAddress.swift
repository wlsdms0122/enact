//
//  StatementAddress.swift
//  Enact
//
//  Created by JSilver on 11/1/26.
//

import Foundation

// Where a statement is recorded: the names of the scenario statements it ran
// under, outermost first, its own last. A statement written with no name is
// named by its position, `[2]`, as Warp names it.
struct StatementAddress: Hashable, Sendable, CustomStringConvertible {
    // MARK: - Property
    let segments: [String]
    
    var description: String { segments.joined(separator: "/") }
    
    // MARK: - Initializer
    init(_ segments: [String] = []) {
        self.segments = segments
    }
    
    // MARK: - Public
    func appending(_ label: String) -> StatementAddress {
        StatementAddress(segments + [label])
    }
    
    // MARK: - Private
}

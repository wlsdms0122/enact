//
//  QueryRefused.swift
//  Enact
//
//  Created by JSilver on 11/13/26.
//

import Foundation

// A procedure named as a query of a screen that is no such query: not
// declared, not public, or not a const and isolated procedure of one
// `Enact.Screen`.
public struct QueryRefused: Error, CustomStringConvertible {
    // MARK: - Property
    public let description: String
    
    // MARK: - Initializer
    init(_ description: String) {
        self.description = description
    }
    
    // MARK: - Public
    // MARK: - Private
}

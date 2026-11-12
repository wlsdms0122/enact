//
//  InputRefused.swift
//  Enact
//
//  Created by JSilver on 10/31/26.
//

import Foundation

// An input the scenario's entry does not take, or takes as something the
// text given does not spell, or one it needs and was not given.
public struct InputRefused: Error, CustomStringConvertible {
    // MARK: - Property
    public let description: String
    
    // MARK: - Initializer
    init(_ description: String) {
        self.description = description
    }
    
    // MARK: - Public
    // MARK: - Private
}

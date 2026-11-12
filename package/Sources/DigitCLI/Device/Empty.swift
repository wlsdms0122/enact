//
//  Empty.swift
//  DigitCLI
//
//  Created by JSilver on 11/10/26.
//

import Foundation

// The answer of a command that answers nothing, null in JSON.
package struct Empty: Encodable, Sendable {
    // MARK: - Property
    // MARK: - Initializer
    package init() {}
    
    // MARK: - Public
    package func encode(to encoder: any Encoder) throws {
        var container = encoder.singleValueContainer()
        
        try container.encodeNil()
    }
    
    // MARK: - Private
}

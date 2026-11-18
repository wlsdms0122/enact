//
//  Input.swift
//  EnactCLI
//
//  Created by JSilver on 8/16/26.
//

import ArgumentParser
import Foundation

// An input as written on the command line, name=text. The scenario's entry
// says what type the text is read as.
struct Input: ExpressibleByArgument, Equatable {
    // MARK: - Property
    let name: String
    let text: String
    
    // MARK: - Initializer
    init?(argument: String) {
        guard let split = argument.firstIndex(of: "="), split != argument.startIndex else { return nil }
        
        name = String(argument[argument.startIndex..<split])
        text = String(argument[argument.index(after: split)...])
    }
    
    // MARK: - Public
    // MARK: - Private
}

//
//  ScenarioLookupError.swift
//  Enact
//
//  Created by JSilver on 10/31/26.
//

import Foundation

public enum ScenarioLookupError: Error, CustomStringConvertible {
    case notFound(name: String)
    case entryMissing(name: String)
    case declaredTwice(name: String, files: [String])
    case noDirectory(path: String)
    
    // MARK: - Property
    public var description: String {
        switch self {
        case let .notFound(name):
            "no scenario declares the name '\(name)'"
        
        case let .entryMissing(name):
            "'\(name)' declares no public procedure called main, which a run starts from"
        
        case let .declaredTwice(name, files):
            "'\(name)' is declared by more than one scenario: \(files.joined(separator: ", "))"
        
        case let .noDirectory(path):
            "no directory to find scenarios in at \(path)"
        }
    }
    
    // MARK: - Initializer
    // MARK: - Public
    // MARK: - Private
}

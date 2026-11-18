//
//  ScenarioReference.swift
//  Enact
//
//  Created by JSilver on 8/16/26.
//

import Foundation

public enum ScenarioReference: Equatable, Sendable {
    case stdin
    case path(String)
    case name(String)
    
    // MARK: - Property
    // MARK: - Initializer
    public init(_ raw: String) {
        if raw == "-" {
            self = .stdin
        } else if raw.contains("/") || raw.hasSuffix(".yaml") || raw.hasSuffix(".yml") {
            self = .path(raw)
        } else {
            self = .name(raw)
        }
    }
    
    // MARK: - Public
    // MARK: - Private
}

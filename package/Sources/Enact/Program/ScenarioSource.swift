//
//  ScenarioSource.swift
//  Enact
//
//  Created by JSilver on 11/12/26.
//

import Foundation

// A scenario's text, the file it was read from, and the name it is found
// under, none for a text that declares none.
public struct ScenarioSource: Sendable, Equatable {
    // MARK: - Property
    public let name: String?
    public let file: String
    public let text: String
    
    // The file wherever it is reached from, so one file reached twice is one.
    var location: String {
        URL(fileURLWithPath: file).standardizedFileURL.resolvingSymlinksInPath().path
    }
    
    // MARK: - Initializer
    public init(name: String?, file: String, text: String) {
        self.name = name
        self.file = file
        self.text = text
    }
    
    // MARK: - Public
    // MARK: - Private
}

//
//  PinnedStore.swift
//  Enact
//
//  Created by JSilver on 8/16/26.
//

import EnactWarp
import Foundation

// A text handed as the one to run, beside the scenarios the rest finds. It is
// found under the name it declares, or where it declares none, its file's
// name: `-` for one read from stdin.
public struct PinnedStore: ScenarioStore {
    // MARK: - Property
    public let name: String
    let pinned: ScenarioSource
    let rest: ScenarioStore
    
    // MARK: - Initializer
    public init(file: String, text: String, rest: ScenarioStore) {
        self.name = ScenarioHeader(text).module ?? URL(fileURLWithPath: file).deletingPathExtension().lastPathComponent
        self.pinned = ScenarioSource(name: name, file: file, text: text)
        self.rest = rest
    }
    
    // MARK: - Public
    // A file the rest finds as well is the pinned one.
    public func sources() throws -> [ScenarioSource] {
        try [pinned] + rest.sources().filter { source in source.location != pinned.location }
    }
    
    // MARK: - Private
}

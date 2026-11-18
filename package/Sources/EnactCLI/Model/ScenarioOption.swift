//
//  ScenarioOption.swift
//  EnactCLI
//
//  Created by JSilver on 8/16/26.
//

import ArgumentParser
import Digit
import DigitCLI
import Enact
import Foundation

struct ScenarioOption: ParsableArguments {
    // MARK: - Property
    @Argument(help: "Scenario: the name one declares (found in --path), a file path, or '-' for stdin.")
    var scenario: String
    
    @Option(name: .customLong("path"), help: "A directory scenarios are found in, at any depth. Repeatable.")
    var paths: [String] = []
    
    // MARK: - Initializer
    // MARK: - Public
    // The scenario a run starts from, by the name it is found under, and the
    // store it and every scenario it calls are found in. The scenarios a run
    // may call are those under --path alone, wherever the file run is.
    func entry() throws -> (name: String, store: ScenarioStore) {
        let roots = paths.map { URL(fileURLWithPath: $0, isDirectory: true) }
        
        switch ScenarioReference(scenario) {
        case .stdin:
            let text = try StandardInput().text(as: "scenario")
            let store = PinnedStore(file: "-", text: text, rest: SearchPathStore(roots: roots))
            
            return (store.name, store)
        
        case let .path(path):
            let text: String
            
            do {
                text = try String(contentsOf: URL(fileURLWithPath: path), encoding: .utf8)
            } catch {
                throw ValidationError("cannot read \(path): \(error.localizedDescription)")
            }
            
            let store = PinnedStore(file: path, text: text, rest: SearchPathStore(roots: roots))
            
            return (store.name, store)
        
        case let .name(name):
            guard !roots.isEmpty else {
                throw ValidationError("'\(name)' is a name, and a name resolves in --path")
            }
            
            return (name, SearchPathStore(roots: roots))
        }
    }
    
    // MARK: - Private
}

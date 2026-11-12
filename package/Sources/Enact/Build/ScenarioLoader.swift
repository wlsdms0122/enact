//
//  ScenarioLoader.swift
//  Enact
//
//  Created by JSilver on 10/31/26.
//

import EnactWarp
import Foundation
import Warp
import WarpSyntax
import WarpYAML

// Reads a scenario and every scenario it calls out of a store. A scenario is
// found under the name its text declares, whatever its file is called, and
// calls another through that name, `Login.main` for a text that writes
// `name: Login`, using it as the module of that name, `uses: [Login]`. Every
// scenario the store finds is a module the text may use, so a call names its
// arguments as any call does. A text that does not read, declares no name, or
// declares one of the vocabulary's modules, is no module, and is refused
// where a scenario calls it, and a name two texts declare is refused where it
// is run or a text uses it.
struct ScenarioLoader: Sendable {
    // MARK: - Property
    let vocabulary: EnactVocabulary
    let store: ScenarioStore
    
    // MARK: - Initializer
    init(vocabulary: EnactVocabulary, store: ScenarioStore) {
        self.vocabulary = vocabulary
        self.store = store
    }
    
    // MARK: - Public
    // The scenario under the name and the scenarios it calls, by name.
    func load(_ name: String) throws -> [String: ScenarioDocument] {
        let named = try store.sources().reduce(into: [String: [ScenarioSource]]()) { named, source in
            guard let module = source.name, !EnactVocabulary.modules.contains(module) else { return }
            
            named[module, default: []].append(source)
        }
        
        guard let entry = named[name] else { throw ScenarioLookupError.notFound(name: name) }
        guard entry.count == 1 else { throw ScenarioLookupError.declaredTwice(name: name, files: entry.map(\.file)) }
        
        let modules = named.sorted { one, other in one.key < other.key }.compactMap { module, found -> (module: String, text: String)? in
            guard module != name, found.count == 1, let text = found.first?.text else { return nil }
            guard (try? vocabulary.frontend(dependingOn: [(module, text)])) != nil else { return nil }
            
            return (module, text)
        }
        let frontend = try vocabulary.frontend(dependingOn: modules)
        var documents: [String: ScenarioDocument] = [:]
        var pending = [name]
        
        while let next = pending.popLast() {
            guard documents[next] == nil, let source = named[next]?.first else { continue }
            
            if let twice = ScenarioHeader(source.text).uses.first(where: { module in (named[module]?.count ?? 0) > 1 }) {
                throw ScenarioLookupError.declaredTwice(name: twice, files: named[twice, default: []].map(\.file))
            }
            
            let document = try self.document(of: source, by: frontend)
            
            documents[next] = document
            pending += document.called.compactMap { called in
                guard let module = module(calledAs: called), named[module]?.count == 1 else { return nil }
                
                return module
            }
        }
        
        return documents
    }
    
    // The scenario among the documents a call reaches: the one under the name
    // the called procedure's name starts with.
    func scenario(calledAs called: String, among documents: [String: ScenarioDocument]) -> String? {
        guard let module = module(calledAs: called), documents[module] != nil else { return nil }
        
        return module
    }
    
    // MARK: - Private
    // A scenario's text spent and loaded, refused at the line and column of
    // its file where the front end or the load refuses it.
    private func document(of source: ScenarioSource, by frontend: YAMLFrontend) throws -> ScenarioDocument {
        let written: (document: Data, origin: Origin)
        
        do {
            written = try frontend.document(from: source.text)
        } catch let refused as TextRefused {
            throw ScenarioRefused(file: source.file, refused: refused)
        }
        
        do {
            return try ScenarioDocument(
                try BinaryEncoding().value(from: written.document),
                origin: written.origin,
                file: source.file
            )
        } catch let refused as any WarpError {
            throw ScenarioRefused(file: source.file, refused: refused, origin: written.origin)
        }
    }
    
    // The module a call names: the head of a procedure's full name, and nil
    // for a short name, which no scenario is called by.
    private func module(calledAs called: String) -> String? {
        guard let dot = called.firstIndex(of: ".") else { return nil }
        
        return String(called[..<dot])
    }
}

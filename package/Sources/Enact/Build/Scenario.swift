//
//  Scenario.swift
//  Enact
//
//  Created by JSilver on 10/31/26.
//

import EnactWarp
import Foundation
import Warp

// A scenario built: the image of it and the scenarios it calls, the
// procedure a run starts from, and what each scenario calls and can ask a
// device to do.
public struct Scenario: Sendable {
    public struct Calls: Sendable, Equatable {
        // MARK: - Property
        public let scenario: String
        public let calls: [String]
        public let verbs: [String]
        
        // MARK: - Initializer
        // MARK: - Public
        // MARK: - Private
    }
    
    // MARK: - Property
    public let name: String
    public let scenarios: [String]
    public let graph: [Calls]
    
    // None for a scenario with no public `main`, which builds for the
    // scenarios that call it and is not run.
    public let entry: ScenarioEntry?
    
    let image: Image
    
    // MARK: - Initializer
    init(name: String, loader: ScenarioLoader, builder: ScenarioBuilder) async throws {
        let documents = try loader.load(name)
        
        let image: Image
        
        do {
            image = try await builder.image(of: documents.keys.sorted().compactMap { found in documents[found]?.module })
        } catch let refused as any WarpError {
            throw ScenarioRefused(refused, among: documents)
        }
        
        self.name = name
        self.scenarios = documents.keys.sorted()
        self.graph = try documents.keys.sorted().map { found in
            let document = documents[found]
            let calls = Set((document?.called ?? []).compactMap { called in
                loader.scenario(calledAs: called, among: documents.filter { other, _ in other != found })
            })
            let verbs = try document?.entry.map { entry in
                Set(try EnactVocabulary.operations(reachedFrom: entry, in: image).values.joined())
            } ?? []
            
            return Calls(scenario: found, calls: calls.sorted(), verbs: verbs.sorted())
        }
        self.image = image
        self.entry = ScenarioEntry(named: name, among: documents, vocabulary: loader.vocabulary)
    }
    
    // MARK: - Public
    // MARK: - Private
}

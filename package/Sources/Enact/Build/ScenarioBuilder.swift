//
//  ScenarioBuilder.swift
//  Enact
//
//  Created by JSilver on 10/31/26.
//

import EnactWarp
import Foundation
import Warp

// The vocabulary is compiled once and laid down for a compile against it to
// read. Scenarios are compiled together against it, since one may call
// another, and linked beside it.
struct ScenarioBuilder: Sendable {
    // MARK: - Property
    let vocabulary: EnactVocabulary
    
    private let built: Task<(compiled: [Compiled], laid: Laid, supplying: Supplying), any Error>
    
    // MARK: - Initializer
    init(vocabulary: EnactVocabulary) {
        self.vocabulary = vocabulary
        self.built = Task {
            let modules = vocabulary.linkables
            let supplying = try Supplying(modules)
            let compiled = try await Builder().compile(modules, against: [], supplying: supplying)
            
            return (compiled: compiled, laid: try Builder().lay(compiled, supplying: supplying), supplying: supplying)
        }
    }
    
    // MARK: - Public
    func image(of scenarios: [Module]) async throws -> Image {
        let vocabulary = try await built.value
        let compiled = try await Builder().compile(scenarios, against: vocabulary.laid)
        
        return try Builder().link(vocabulary.compiled + compiled, supplying: vocabulary.supplying)
    }
    
    // MARK: - Private
}

//
//  ScenarioHeader.swift
//  EnactWarp
//
//  Created by JSilver on 11/4/26.
//

import Foundation
import Yams

// What a scenario's text says of itself as a module: the name it declares,
// which is the module a caller uses, and the modules it writes under `uses:`.
// A text that does not read as YAML says neither.
package struct ScenarioHeader: Sendable, Equatable {
    // MARK: - Property
    package let module: String?
    package let uses: [String]
    
    // MARK: - Initializer
    package init(_ text: String) {
        let written = (try? Yams.load(yaml: text)) as? [String: Any]
        
        self.module = written?["name"] as? String
        self.uses = written?["uses"] as? [String] ?? []
    }
    
    // MARK: - Public
    // MARK: - Private
}

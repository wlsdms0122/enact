//
//  ScenarioDocument.swift
//  Enact
//
//  Created by JSilver on 10/31/26.
//

import Foundation
import Warp
import WarpSyntax
import WarpYAML

// A scenario as the front end wrote it: its document and where in the text
// each of its places stands, the module the build takes, the file its text
// was read from, and every procedure it calls by name.
struct ScenarioDocument: Sendable {
    // MARK: - Property
    let document: Warp.Value
    let origin: Origin
    let module: Module
    let file: String
    let called: Set<String>
    
    // The procedures the document declares at its top, as it writes them.
    var procedures: [String: Warp.Value] {
        guard case let .dictionary(fields) = document, case let .dictionary(declared)? = fields["procedures"] else {
            return [:]
        }
        
        return declared.entries.reduce(into: [:]) { procedures, entry in
            guard case let .string(name) = entry.key else { return }
            
            procedures[name] = entry.value
        }
    }
    
    // The procedure a run of this scenario starts from: its public one
    // called main, the shortest spelling where a text declares more than one.
    var entry: Warp.Name? {
        module.procedures.keys
            .filter { name in name.spelling.split(separator: ".").last == "main" && module.procedures[name]?.access == .public }
            .min { one, other in (one.spelling.count, one.spelling) < (other.spelling.count, other.spelling) }
    }
    
    // MARK: - Initializer
    init(_ document: Warp.Value, origin: Origin, file: String) throws {
        self.document = document
        self.origin = origin
        self.module = try Loader().load(document)
        self.file = file
        self.called = Self.strings(under: ["procedure"], in: document)
    }
    
    // MARK: - Public
    // MARK: - Private
    // A call names its procedure under `procedure`, wherever in the document
    // it stands.
    private static func strings(under keys: Set<String>, in value: Warp.Value) -> Set<String> {
        switch value {
        case let .dictionary(entries):
            entries.entries.reduce(into: []) { names, entry in
                if case let .string(key) = entry.key, keys.contains(key), case let .string(name) = entry.value {
                    names.insert(name)
                }
                
                names.formUnion(Self.strings(under: keys, in: entry.value))
            }
        
        case let .array(items):
            items.reduce(into: []) { names, item in names.formUnion(Self.strings(under: keys, in: item)) }
        
        case let .struct(held):
            held.values.reduce(into: []) { names, field in names.formUnion(Self.strings(under: keys, in: field)) }
        
        default:
            []
        }
    }
}

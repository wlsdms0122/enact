//
//  ScenarioEntry.swift
//  Enact
//
//  Created by JSilver on 11/9/26.
//

import EnactWarp
import Foundation
import Warp

// The procedure a run of a scenario starts from, its public `main`: the
// statements a stop is an address of, and the inputs it takes.
public struct ScenarioEntry: Sendable {
    // MARK: - Property
    let scenario: String
    let name: Warp.Name
    let statements: StatementTree
    let parameters: [Parameter]
    
    // The declared types that are text, which an input's text is read as.
    let texts: Set<Warp.Name>
    
    // The declared enums, with their cases that carry nothing, which an
    // input's text names one of.
    let cases: [Warp.Name: Set<String>]
    
    // MARK: - Initializer
    // None where the scenario declares no public `main`.
    init?(named scenario: String, among documents: [String: ScenarioDocument], vocabulary: EnactVocabulary) {
        guard let root = documents[scenario], let entry = root.entry, let procedure = root.module.procedures[entry] else {
            return nil
        }
        
        self.scenario = scenario
        self.name = entry
        self.statements = StatementTree(
            procedures: documents.values.reduce(into: [:]) { procedures, document in
                procedures.merge(document.procedures) { declared, _ in declared }
            },
            entry: entry
        )
        self.parameters = procedure.signature.parameters
        self.texts = Set(
            root.module.types.compactMap { declared, type in
                guard case .alias(.string) = type else { return nil }
                
                return declared
            }
        )
        self.cases = (vocabulary.linkables + [root.module]).reduce(into: [:]) { cases, module in
            for case let (declared, .enum(carried, _, _)) in module.types {
                cases[declared] = Set(carried.filter { _, fields in fields.isEmpty }.keys.map(\.spelling))
            }
        }
    }
    
    // MARK: - Public
    // The entry's arguments, each input's text read as the type its parameter
    // declares.
    func arguments(from inputs: [String: String]) throws -> [Warp.Name: Warp.Value] {
        if let unknown = inputs.keys.sorted().first(where: { given in !parameters.contains { parameter in parameter.name.spelling == given } }) {
            throw InputRefused(
                "\(scenario) takes no input called '\(unknown)': "
                    + parameters.map(\.name.spelling).joined(separator: ", ")
            )
        }
        
        return try parameters.reduce(into: [:]) { arguments, parameter in
            guard let written = inputs[parameter.name.spelling] else {
                guard case .optional = parameter.type else {
                    throw InputRefused("\(scenario) needs the input '\(parameter.name.spelling)'")
                }
                
                arguments[parameter.name] = .null
                
                return
            }
            
            arguments[parameter.name] = try value(of: written, as: parameter.type, for: parameter.name.spelling)
        }
    }
    
    // MARK: - Private
    private func value(of written: String, as type: TypeExpression, for input: String) throws -> Warp.Value {
        let refused = InputRefused("\(input) is \(type), and '\(written)' does not spell one")
        
        switch type {
        case let .optional(wrapped):
            return try value(of: written, as: wrapped, for: input)
        
        case .bool:
            guard written == "true" || written == "false" else { throw refused }
            
            return .bool(written == "true")
        
        case .int:
            guard let number = Int(written) else { throw refused }
            
            return .int(number)
        
        case .double:
            guard let number = Double(written), number.isFinite else { throw refused }
            
            return .double(number)
        
        case .string, .any:
            return .string(written)
        
        case let .named(declared, _) where texts.contains(declared):
            return .string(written)
        
        case let .named(declared, _) where cases[declared]?.contains(written) == true:
            return try EnumCase(written, of: declared).value()
        
        default:
            throw refused
        }
    }
}

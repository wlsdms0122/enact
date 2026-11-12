//
//  StatementTree.swift
//  Enact
//
//  Created by JSilver on 11/1/26.
//

import Foundation
import Warp

// The scenario statements a run can reach, as the journal records them: the
// statements of a body a statement holds (a closure it hands a verb, a branch,
// a loop, a try) and of a scenario procedure it calls stand under it. Read off
// the scenarios' documents, whose statements and constructs the document
// format spells.
struct StatementTree: Sendable {
    // MARK: - Property
    // The keys a statement names what it binds under. A `set` names a path,
    // and the statement is called by its head.
    private static let namingKeys: [Warp.Name] = ["let", "var", "set"]
    private static let pathMarks: Set<Character> = [".", "[", "?"]
    
    // The keys a construct or a procedure holds a body under.
    private static let bodyKeys: Set<String> = ["body", "then", "else", "catch", "default"]
    
    // Every address short of a procedure called inside itself.
    let addresses: Set<StatementAddress>
    
    // A call of a procedure inside itself, and where each procedure it calls
    // so was entered: what stands under the one stands under the other. An
    // entry is always shorter than the call, so reading one back ends.
    private let reentries: [StatementAddress: Set<StatementAddress>]
    
    private static let empty = StatementTree(addresses: [], reentries: [:])
    
    // MARK: - Initializer
    init(procedures: [String: Warp.Value], entry: Warp.Name) {
        guard let procedure = procedures[entry.spelling] else {
            self = Self.empty
            return
        }
        
        self = Self.tree(
            in: procedure,
            under: StatementAddress(),
            entered: [entry.spelling: StatementAddress()],
            procedures: procedures
        )
    }
    
    private init(addresses: Set<StatementAddress>, reentries: [StatementAddress: Set<StatementAddress>]) {
        self.addresses = addresses
        self.reentries = reentries
    }
    
    // MARK: - Public
    func contains(_ address: StatementAddress) -> Bool {
        guard !addresses.contains(address) else { return true }
        
        for count in (1..<max(address.segments.count, 1)).reversed() {
            guard let entries = reentries[StatementAddress(Array(address.segments.prefix(count)))] else { continue }
            
            let held = entries.contains { entered in
                contains(StatementAddress(entered.segments + address.segments.dropFirst(count)))
            }
            
            if held { return true }
        }
        
        return false
    }
    
    // The addresses of the statements a name calls, outside a procedure
    // called inside itself.
    func addresses(named label: String) -> [StatementAddress] {
        addresses
            .filter { address in address.segments.last == label }
            .sorted { one, other in one.description < other.description }
    }
    
    // MARK: - Private
    private func union(_ other: StatementTree) -> StatementTree {
        StatementTree(
            addresses: addresses.union(other.addresses),
            reentries: reentries.merging(other.reentries) { held, more in held.union(more) }
        )
    }
    
    private static func tree(
        ofBody statements: [Warp.Value],
        under parent: StatementAddress,
        entered: [String: StatementAddress],
        procedures: [String: Warp.Value]
    ) -> StatementTree {
        statements.enumerated().reduce(into: empty) { found, statement in
            let address = parent.appending(name(of: statement.element) ?? "[\(statement.offset)]")
            
            found = found.union(StatementTree(addresses: [address], reentries: [:]))
            
            if case let .dictionary(fields) = statement.element, let value = fields["value"] {
                found = found.union(tree(in: value, under: address, entered: entered, procedures: procedures))
            }
        }
    }
    
    // Every body under a value, at any depth. A struct or a case literal names
    // its fields as its author chose, so they are read as values only.
    private static func tree(
        in value: Warp.Value,
        under address: StatementAddress,
        entered: [String: StatementAddress],
        procedures: [String: Warp.Value]
    ) -> StatementTree {
        let inner = { (value: Warp.Value) in tree(in: value, under: address, entered: entered, procedures: procedures) }
        
        switch value {
        case let .array(items):
            return items.reduce(empty) { found, item in found.union(inner(item)) }
        
        case let .dictionary(fields):
            return fields.entries.reduce(empty) { found, field in
                guard case let .string(key) = field.key else { return found }
                
                switch (key, field.value) {
                case let (key, .array(statements)) where bodyKeys.contains(key):
                    return found.union(
                        tree(ofBody: statements, under: address, entered: entered, procedures: procedures)
                    )
                
                case let ("struct", .dictionary(written)):
                    return found.union(tree(inValuesOf: written, under: address, entered: entered, procedures: procedures))
                
                case let ("case", .dictionary(written)):
                    return written.entries.reduce(found) { found, label in
                        guard case let .dictionary(carried) = label.value else { return found }
                        
                        return found.union(
                            tree(inValuesOf: carried, under: address, entered: entered, procedures: procedures)
                        )
                    }
                
                case let ("procedure", .string(called)):
                    guard let callee = procedures[called] else { return found }
                    
                    guard let enteredAt = entered[called] else {
                        var entering = entered
                        entering[called] = address
                        
                        return found.union(tree(in: callee, under: address, entered: entering, procedures: procedures))
                    }
                    
                    // Called again where it was entered, as from its result, it holds
                    // the statements it already stands under.
                    guard enteredAt != address else { return found }
                    
                    return found.union(StatementTree(addresses: [], reentries: [address: [enteredAt]]))
                
                default:
                    return found.union(inner(field.value))
                }
            }
        
        default:
            return empty
        }
    }
    
    private static func tree(
        inValuesOf fields: Warp.Value.Dictionary,
        under address: StatementAddress,
        entered: [String: StatementAddress],
        procedures: [String: Warp.Value]
    ) -> StatementTree {
        fields.entries.reduce(empty) { found, field in
            found.union(tree(in: field.value, under: address, entered: entered, procedures: procedures))
        }
    }
    
    private static func name(of statement: Warp.Value) -> String? {
        guard case let .dictionary(fields) = statement else { return nil }
        
        for key in namingKeys {
            if case let .string(name)? = fields[key] {
                return String(name.prefix { character in !pathMarks.contains(character) })
            }
        }
        
        return nil
    }
}

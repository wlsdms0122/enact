//
//  DraftNode+Notation.swift
//  EnactCLI
//
//  Created by JSilver on 11/10/26.
//

import Digit
import Foundation

// The expressions of the scenario notation a draft writes.
extension DraftNode {
    // MARK: - Public
    static func call(_ procedure: String, _ arguments: [Entry] = []) -> DraftNode {
        .mapping([
            Entry(
                "call",
                .mapping([Entry("procedure", .plain(procedure))] + (arguments.isEmpty ? [] : [Entry("arguments", .mapping(arguments))]))
            )
        ])
    }
    
    static func ref(_ path: String) -> DraftNode {
        .mapping([Entry("ref", .name(path))])
    }
    
    static func number(_ value: Double) -> DraftNode {
        .plain("\(value)")
    }
    
    static func integer(_ value: Int) -> DraftNode {
        .plain("\(value)")
    }
    
    static func bool(_ value: Bool) -> DraftNode {
        .plain("\(value)")
    }
    
    static func enumCase(_ name: String) -> DraftNode {
        .mapping([Entry("case", .plain(name))])
    }
    
    static func `struct`(_ fields: [Entry]) -> DraftNode {
        .mapping([Entry("struct", .mapping(fields))])
    }
    
    static func dictionary(_ entries: [Entry]) -> DraftNode {
        .mapping([Entry("dictionary", .mapping(entries))])
    }
    
    // A point given as fractions, to a thousandth, a fraction of a point on
    // any screen.
    static func fraction(_ point: Point) -> DraftNode {
        .struct([
            Entry("x", .number((point.x * 1000).rounded() / 1000)),
            Entry("y", .number((point.y * 1000).rounded() / 1000))
        ])
    }
    
    static func `is`(_ subject: DraftNode, _ other: DraftNode) -> DraftNode {
        .mapping([Entry("of", subject), Entry("is", other)])
    }
    
    static func allOf(_ sides: [DraftNode]) -> DraftNode {
        .mapping([Entry("all_of", .sequence(sides))])
    }
    
    static func closure(
        parameter: String,
        type: String,
        body: [DraftNode] = [],
        result: DraftNode
    ) -> DraftNode {
        .mapping([
            Entry(
                "closure",
                .mapping(
                    [Entry("parameters", .sequence([.mapping([Entry(parameter, .name(type))])]))]
                        + (body.isEmpty ? [] : [Entry("body", .sequence(body))])
                        + [Entry("result", result)]
                )
            )
        ])
    }
    
    static func closure(returns type: String, result: DraftNode) -> DraftNode {
        .mapping([Entry("closure", .mapping([Entry("returns", .name(type)), Entry("result", result)]))])
    }
    
    static func `let`(_ name: String, type: String, value: DraftNode) -> DraftNode {
        .mapping([Entry("let", .plain(name)), Entry("type", .name(type)), Entry("value", value)])
    }
    
    // MARK: - Private
    // A name or a type, plain where the notation reads it as it is written.
    private static func name(_ spelling: String) -> DraftNode {
        spelling.wholeMatch(of: /[A-Za-z_][A-Za-z0-9_.]*/) == nil ? .quoted(spelling) : .plain(spelling)
    }
}

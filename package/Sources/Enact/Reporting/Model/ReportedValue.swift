//
//  ReportedValue.swift
//  Enact
//
//  Created by JSilver on 10/31/26.
//

import EnactWarp
import Foundation
import Warp

// A value a run returned, as a report writes it: as JSON in the shape the value
// has, a struct and a dictionary of text keys as an object, a value of an enum
// as an object of its case alone holding what it carries (`{"up":{}}`), and on
// one line as that JSON.
public struct ReportedValue: Sendable, Encodable, Equatable, CustomStringConvertible {
    // MARK: - Property
    let value: Warp.Value
    
    // The enums the run's image declares, whose values are structs under their
    // cases' spellings.
    let enums: Set<Warp.Name>
    
    public var description: String {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.sortedKeys, .withoutEscapingSlashes]
        
        return (try? encoder.encode(self)).map { data in String(decoding: data, as: UTF8.self) } ?? "\(value)"
    }
    
    // The JSON cut to a line a terminal holds.
    public var summary: String {
        let written = description
        
        return written.count > 120 ? String(written.prefix(119)) + "…" : written
    }
    
    // MARK: - Initializer
    init(_ value: Warp.Value, enums: Set<Warp.Name>) {
        self.value = value
        self.enums = enums
    }
    
    // MARK: - Public
    // Two are the same where they write the same JSON.
    public static func == (lhs: ReportedValue, rhs: ReportedValue) -> Bool {
        lhs.description == rhs.description
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        
        switch value {
        case .null:
            try container.encodeNil()
        
        case let .bool(flag):
            try container.encode(flag)
        
        case let .int(number):
            try container.encode(number)
        
        case let .double(number):
            try container.encode(number)
        
        case let .string(text):
            try container.encode(text)
        
        case let .bytes(bytes):
            try container.encode(bytes)
        
        case let .array(items):
            try container.encode(items.map(reported))
        
        case let .struct(held):
            let fields = Dictionary(uniqueKeysWithValues: zip(held.names.map(\.spelling), held.values.map(reported)))
            
            if let read = EnumCase(value, among: enums) {
                try container.encode([read.name: fields])
            } else {
                try container.encode(fields)
            }
        
        case let .dictionary(entries):
            if let named = try? entries.named() {
                try container.encode(Dictionary(uniqueKeysWithValues: named.map { entry in (entry.name.spelling, reported(entry.value)) }))
            } else {
                try container.encode(entries.entries.map { entry in [reported(entry.key), reported(entry.value)] })
            }
        
        case .procedure, .existential:
            try container.encode("\(value)")
        }
    }
    
    // MARK: - Private
    private func reported(_ value: Warp.Value) -> ReportedValue {
        ReportedValue(value, enums: enums)
    }
}

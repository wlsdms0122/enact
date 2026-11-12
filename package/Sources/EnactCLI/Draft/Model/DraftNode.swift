//
//  DraftNode.swift
//  EnactCLI
//
//  Created by JSilver on 11/10/26.
//

import Foundation

// A node of the YAML a draft writes, in flow style, as the notation writes
// an expression on one line.
indirect enum DraftNode: Equatable {
    struct Entry: Equatable {
        // MARK: - Property
        let key: String
        let value: DraftNode
        
        // MARK: - Initializer
        init(_ key: String, _ value: DraftNode) {
            self.key = key
            self.value = value
        }
        
        // MARK: - Public
        // MARK: - Private
    }
    
    case plain(String)
    case quoted(String)
    case sequence([DraftNode])
    case mapping([Entry])
    
    // MARK: - Property
    var flow: String {
        switch self {
        case let .plain(text):
            text
        
        case let .quoted(text):
            Self.quoting(text)
        
        case let .sequence(items):
            items.isEmpty ? "[]" : "[ \(items.map(\.flow).joined(separator: ", ")) ]"
        
        case let .mapping(entries):
            entries.isEmpty
                ? "{}"
                : "{ \(entries.map { entry in "\(Self.key(entry.key)): \(entry.value.flow)" }.joined(separator: ", ")) }"
        }
    }
    
    // MARK: - Initializer
    // MARK: - Public
    // MARK: - Private
    // A key the notation reads as it is written stays plain.
    private static func key(_ key: String) -> String {
        key.wholeMatch(of: /[A-Za-z_][A-Za-z0-9_]*/) == nil ? quoting(key) : key
    }
    
    // A double-quoted scalar, escaping what it cannot hold as it is.
    private static func quoting(_ text: String) -> String {
        let escaped = text.unicodeScalars.map { scalar in
            switch scalar {
            case "\\":
                "\\\\"
            
            case "\"":
                "\\\""
            
            case "\n":
                "\\n"
            
            case "\t":
                "\\t"
            
            case _ where scalar.value < 0x20 || scalar.value == 0x7F:
                String(format: "\\u%04X", scalar.value)
            
            default:
                String(scalar)
            }
        }
        
        return "\"\(escaped.joined())\""
    }
}

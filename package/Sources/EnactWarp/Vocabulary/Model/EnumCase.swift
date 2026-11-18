//
//  EnumCase.swift
//  EnactWarp
//
//  Created by JSilver on 11/4/26.
//

import Foundation
import Warp

// A case of a declared enum, by the enum's name and its own. A value of it is
// a struct under the case's spelling, the enum's name then the case's,
// holding the fields the case carries.
package struct EnumCase: Sendable, Hashable {
    // MARK: - Property
    package let type: Warp.Name
    package let name: String
    
    // MARK: - Initializer
    package init(_ name: String, of type: Warp.Name) {
        self.type = type
        self.name = name
    }
    
    // The case a value is, of one of the enums given, and nil for a value of
    // none of them.
    package init?(_ value: Warp.Value, among enums: Set<Warp.Name>) {
        guard case let .struct(held) = value, let dot = held.name.spelling.lastIndex(of: ".") else { return nil }
        
        let spelling = held.name.spelling
        let type = Warp.Name(stringLiteral: String(spelling[..<dot]))
        
        guard enums.contains(type) else { return nil }
        
        self.init(String(spelling[spelling.index(after: dot)...]), of: type)
    }
    
    // MARK: - Public
    package func value(carrying fields: [(name: Warp.Name, value: Warp.Value)] = []) throws -> Warp.Value {
        try .holding(fields, named: try Warp.Name("\(type.spelling).\(name)"))
    }
    
    // MARK: - Private
}

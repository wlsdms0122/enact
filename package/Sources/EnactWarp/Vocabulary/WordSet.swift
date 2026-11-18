//
//  WordSet.swift
//  EnactWarp
//
//  Created by JSilver on 11/4/26.
//

import Foundation
import Warp

// A set of words a verb takes, as the enum a scenario writes it: each word a
// case carrying nothing, named as the word's spelling in lower camel case
// (`no-match` is `noMatch`), since a case's name is an identifier.
package struct WordSet<Word: RawRepresentable & CaseIterable & Sendable>: Sendable where Word.RawValue == String {
    // MARK: - Property
    package let name: Warp.Name
    
    var declaration: TypeDeclaration {
        .enum(Dictionary(uniqueKeysWithValues: Word.allCases.map { word in (Warp.Name(stringLiteral: enumCase(of: word).name), [:]) }))
    }
    
    // MARK: - Initializer
    init(_ name: Warp.Name) {
        self.name = name
    }
    
    // MARK: - Public
    func value(of word: Word) throws -> Warp.Value {
        try enumCase(of: word).value()
    }
    
    // The name of the case a word is, as a scenario writes it.
    package func caseName(of word: Word) -> String {
        enumCase(of: word).name
    }
    
    // The word a value of the enum is, nil for what is no case of it.
    func word(of value: Warp.Value) -> Word? {
        guard case let .struct(held) = value, held.isEmpty, let read = EnumCase(value, among: [name]) else { return nil }
        
        return Word.allCases.first { word in enumCase(of: word) == read }
    }
    
    // MARK: - Private
    // The case a word is: its spelling in lower camel case.
    private func enumCase(of word: Word) -> EnumCase {
        let parts = word.rawValue.split(separator: "-").map(String.init)
        
        return EnumCase((parts.prefix(1) + parts.dropFirst().map(\.capitalized)).joined(), of: name)
    }
}

//
//  Invocation+Reading.swift
//  EnactWarp
//
//  Created by JSilver on 10/31/26.
//

import Digit
import Foundation
import Warp

// Reading an argument as the Swift value its declared type stands for. The
// build held each argument to its declaration, so a value of another kind is
// a run that was not built, and refused as one.
extension Invocation {
    func double(_ key: P.Parameters) throws -> Double {
        guard case let .double(number) = self[key] else { throw unbuilt(key) }
        
        return number
    }
    
    func optionalDouble(_ key: P.Parameters) throws -> Double? {
        switch self[key] {
        case let .double(number):
            number
        
        case .null:
            nil
        
        default:
            throw unbuilt(key)
        }
    }
    
    // Seconds to spend: a number that is not negative and not past a year.
    func seconds(_ key: P.Parameters) throws -> Double {
        let seconds = try double(key)
        
        guard seconds.isFinite, (0...31_536_000).contains(seconds) else {
            throw StepFailure(
                .argumentRefused,
                "\(key.declared.name) is \(seconds), and seconds to spend are from 0 to a year"
            )
        }
        
        return seconds
    }
    
    func integer(_ key: P.Parameters) throws -> Int? {
        switch self[key] {
        case let .int(number):
            number
        
        case .null:
            nil
        
        default:
            throw unbuilt(key)
        }
    }
    
    func text(_ key: P.Parameters) throws -> String {
        guard case let .string(text) = self[key] else { throw unbuilt(key) }
        
        return text
    }
    
    func texts(_ key: P.Parameters) throws -> [String] {
        guard case let .array(items) = self[key] else { throw unbuilt(key) }
        
        return try items.map { item in
            guard case let .string(text) = item else { throw unbuilt(key) }
            
            return text
        }
    }
    
    func snapshot(_ key: P.Parameters) throws -> Snapshot {
        try Snapshot(self[key])
    }
    
    // An `Enact.Point`, each coordinate a fraction from 0 to 1.
    func fraction(_ key: P.Parameters) throws -> Point {
        guard case let .struct(held) = self[key],
            case let .double(x) = held["x"],
            case let .double(y) = held["y"]
        else {
            throw unbuilt(key)
        }
        
        guard (0...1).contains(x), (0...1).contains(y) else {
            throw StepFailure(
                .argumentRefused,
                "\(key.declared.name) is { x: \(x), y: \(y) }, and a point is fractions from 0 to 1"
            )
        }
        
        return Point(x: x, y: y)
    }
    
    // Each an `Enact.Coordinate`, held to the latitude and longitude there are.
    func coordinates(_ key: P.Parameters) throws -> [Coordinate] {
        guard case let .array(items) = self[key] else { throw unbuilt(key) }
        
        return try items.map { item in
            guard case let .struct(held) = item,
                case let .double(latitude) = held["lat"],
                case let .double(longitude) = held["lon"]
            else {
                throw unbuilt(key)
            }
            
            return try Coordinate(latitude: latitude, longitude: longitude)
        }
    }
    
    func word<Word>(_ key: P.Parameters, in set: WordSet<Word>) throws -> Word {
        guard let word = set.word(of: self[key]) else { throw unbuilt(key) }
        
        return word
    }
    
    // A word left out, where the declaration takes none, is nil.
    func optionalWord<Word>(_ key: P.Parameters, in set: WordSet<Word>) throws -> Word? {
        guard self[key] != .null else { return nil }
        
        return try word(key, in: set)
    }
    
    func words<Word>(_ key: P.Parameters, in set: WordSet<Word>) throws -> [Word] {
        guard case let .array(items) = self[key] else { throw unbuilt(key) }
        
        return try items.map { item in
            guard let word = set.word(of: item) else { throw unbuilt(key) }
            
            return word
        }
    }
    
    // A dictionary of text keys as the JSON object it stands for. A value
    // JSON writes nothing for, such as a struct or a number that is no
    // number, is refused at the keys that lead to it.
    func json(_ key: P.Parameters) throws -> String {
        guard case .dictionary = self[key] else { throw unbuilt(key) }
        
        let object = try jsonObject(of: self[key], at: key.declared.name.spelling)
        
        return String(decoding: try JSONSerialization.data(withJSONObject: object, options: [.sortedKeys, .withoutEscapingSlashes]), as: UTF8.self)
    }
    
    // A key named or a character typed. A name is written in any case, with
    // spaces or underscores for hyphens.
    func keyPress(_ key: P.Parameters) throws -> KeyPress {
        let written = try text(key)
        let layout = KeyboardLayout()
        
        guard let press = layout.press(named: written) ?? layout.press(named: slugged(written)) else {
            throw StepFailure(
                .argumentRefused,
                "\(key.declared.name): no key called '\(written)', a character or one of "
                    + KeyboardLayout.named.keys.sorted().joined(separator: ", ")
            )
        }
        
        return press
    }
    
    private func jsonObject(of value: Warp.Value, at path: String) throws -> Any {
        let refused = StepFailure(.argumentRefused, "\(path) holds what JSON does not write")
        
        switch value {
        case .null:
            return NSNull()
        
        case let .bool(flag):
            return flag
        
        case let .int(number):
            return number
        
        case let .double(number):
            guard number.isFinite else { throw refused }
            
            return number
        
        case let .string(text):
            return text
        
        case let .array(items):
            return try items.enumerated().map { index, item in try jsonObject(of: item, at: "\(path)[\(index)]") }
        
        case let .dictionary(entries):
            var object: [String: Any] = [:]
            
            for entry in entries.entries {
                guard case let .string(key) = entry.key else { throw refused }
                
                object[key] = try jsonObject(of: entry.value, at: "\(path).\(key)")
            }
            
            return object
        
        default:
            throw refused
        }
    }
    
    private func slugged(_ written: String) -> String {
        written.lowercased()
            .split { character in character == " " || character == "_" }
            .joined(separator: "-")
    }
    
    private func unbuilt(_ key: P.Parameters) -> RunRefused {
        RunRefused(
            "'\(selector)' was handed \(self[key]) for \(key.declared.name), where \(key.declared.type) is declared"
        )
    }
}

//
//  WordSplitter.swift
//  DigitCLI
//
//  Created by JSilver on 11/10/26.
//

import ArgumentParser
import Foundation

// Splits a line into words as a POSIX shell does, with quoting and escapes and
// nothing expanded: blanks separate words, single quotes keep everything
// literally, double quotes keep everything but `\"` and `\\`, and a backslash
// outside quotes keeps the next character.
struct WordSplitter {
    // MARK: - Property
    // MARK: - Initializer
    // MARK: - Public
    func split(_ line: String) throws -> [String] {
        let characters = Array(line)
        var words: [String] = []
        var word: String?
        var index = 0
        
        while index < characters.count {
            let character = characters[index]
            index += 1
            
            if character.isWhitespace {
                if let word { words.append(word) }
                
                word = nil
                continue
            }
            
            var part: String
            
            switch character {
            case "'":
                (part, index) = try singleQuoted(characters, from: index)
            
            case "\"":
                (part, index) = try doubleQuoted(characters, from: index)
            
            case "\\":
                guard index < characters.count else {
                    throw ValidationError("the line ends in a backslash with nothing to escape")
                }
                
                part = String(characters[index])
                index += 1
            
            default:
                part = String(character)
            }
            
            word = (word ?? "") + part
        }
        
        if let word { words.append(word) }
        
        return words
    }
    
    // MARK: - Private
    private func singleQuoted(_ characters: [Character], from start: Int) throws -> (String, Int) {
        guard let close = characters[start...].firstIndex(of: "'") else {
            throw ValidationError("a single quote is never closed")
        }
        
        return (String(characters[start..<close]), close + 1)
    }
    
    private func doubleQuoted(_ characters: [Character], from start: Int) throws -> (String, Int) {
        var quoted = ""
        var index = start
        
        while index < characters.count {
            let character = characters[index]
            index += 1
            
            switch character {
            case "\"":
                return (quoted, index)
            
            case "\\" where index < characters.count && ["\"", "\\"].contains(characters[index]):
                quoted.append(characters[index])
                index += 1
            
            default:
                quoted.append(character)
            }
        }
        
        throw ValidationError("a double quote is never closed")
    }
}

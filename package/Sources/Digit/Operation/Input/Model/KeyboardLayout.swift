//
//  KeyboardLayout.swift
//  Digit
//
//  Created by JSilver on 8/16/26.
//

import Foundation

public struct KeyboardLayout {
    // MARK: - Property
    public static let returnKey: UInt32 = 40
    public static let escape: UInt32 = 41
    public static let delete: UInt32 = 42
    public static let tab: UInt32 = 43
    public static let space: UInt32 = 44
    public static let rightArrow: UInt32 = 79
    public static let leftArrow: UInt32 = 80
    public static let downArrow: UInt32 = 81
    public static let upArrow: UInt32 = 82
    public static let home: UInt32 = 74
    public static let pageUp: UInt32 = 75
    public static let end: UInt32 = 77
    public static let pageDown: UInt32 = 78
    static let letters: ClosedRange<UInt32> = 4...29
    
    public static let named: [String: UInt32] = [
        "return": returnKey, "enter": returnKey,
        "escape": escape, "esc": escape,
        "delete": delete, "backspace": delete,
        "tab": tab, "space": space,
        "right": rightArrow, "left": leftArrow, "down": downArrow, "up": upArrow,
        "home": home, "end": end, "page-up": pageUp, "page-down": pageDown
    ]
    
    private static let unshifted: [Character: UInt32] = [
        " ": space, "\t": tab, "\n": returnKey,
        "-": 45, "=": 46, "[": 47, "]": 48, "\\": 49,
        ";": 51, "'": 52, "`": 53, ",": 54, ".": 55, "/": 56
    ]
    
    private static let shiftedSymbols: [Character: UInt32] = [
        "!": 30, "@": 31, "#": 32, "$": 33, "%": 34,
        "^": 35, "&": 36, "*": 37, "(": 38, ")": 39,
        "_": 45, "+": 46, "{": 47, "}": 48, "|": 49,
        ":": 51, "\"": 52, "~": 53, "<": 54, ">": 55, "?": 56
    ]
    
    // MARK: - Initializer
    public init() {}
    
    // MARK: - Public
    public func press(for character: Character) -> KeyPress? {
        if character.isLetter,
            character.isASCII,
            let lower = character.lowercased().first,
            let ascii = lower.asciiValue {
            return KeyPress(code: Self.letters.lowerBound + UInt32(ascii - 97), shifted: character.isUppercase)
        }
        
        if character.isNumber, character.isASCII, let ascii = character.asciiValue {
            return KeyPress(code: character == "0" ? 39 : UInt32(ascii - 49) + 30)
        }
        
        if let code = Self.unshifted[character] { return KeyPress(code: code) }
        if let code = Self.shiftedSymbols[character] { return KeyPress(code: code, shifted: true) }
        
        return nil
    }
    
    public func press(named name: String) -> KeyPress? {
        if let code = Self.named[name.lowercased()] { return KeyPress(code: code) }
        if name.count == 1, let character = name.first { return press(for: character) }
        
        return nil
    }
    
    // MARK: - Private
}

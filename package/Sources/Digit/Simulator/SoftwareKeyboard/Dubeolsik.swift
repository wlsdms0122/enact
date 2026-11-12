//
//  Dubeolsik.swift
//  Digit
//
//  Created by JSilver on 11/9/26.
//

import Foundation

// The Korean two-set input method of the iOS software keyboard: a key for each jamo, the
// tense consonants and ㅒ ㅖ among them. A syllable is spelled as its jamo, a compound
// vowel or final as the two keys the keyboard composes it from.
struct Dubeolsik: InputMethod {
    // MARK: - Property
    private static let keys: Set<Character> = Set(
        "ㅂㅈㄷㄱㅅㅛㅕㅑㅐㅔㅁㄴㅇㄹㅎㅗㅓㅏㅣㅋㅌㅊㅍㅠㅜㅡ" + "ㅃㅉㄸㄲㅆㅒㅖ"
    )
    private static let syllables: ClosedRange<UInt32> = 0xAC00...0xD7A3
    private static let leading: [String] = [
        "ㄱ", "ㄲ", "ㄴ", "ㄷ", "ㄸ", "ㄹ", "ㅁ", "ㅂ", "ㅃ", "ㅅ",
        "ㅆ", "ㅇ", "ㅈ", "ㅉ", "ㅊ", "ㅋ", "ㅌ", "ㅍ", "ㅎ"
    ]
    private static let vowels: [String] = [
        "ㅏ", "ㅐ", "ㅑ", "ㅒ", "ㅓ", "ㅔ", "ㅕ", "ㅖ", "ㅗ", "ㅗㅏ", "ㅗㅐ",
        "ㅗㅣ", "ㅛ", "ㅜ", "ㅜㅓ", "ㅜㅔ", "ㅜㅣ", "ㅠ", "ㅡ", "ㅡㅣ", "ㅣ"
    ]
    private static let trailing: [String] = [
        "", "ㄱ", "ㄲ", "ㄱㅅ", "ㄴ", "ㄴㅈ", "ㄴㅎ", "ㄷ", "ㄹ", "ㄹㄱ", "ㄹㅁ", "ㄹㅂ",
        "ㄹㅅ", "ㄹㅌ", "ㄹㅍ", "ㄹㅎ", "ㅁ", "ㅂ", "ㅂㅅ", "ㅅ", "ㅆ", "ㅇ", "ㅈ", "ㅊ",
        "ㅋ", "ㅌ", "ㅍ", "ㅎ"
    ]
    
    // MARK: - Initializer
    // MARK: - Public
    func spelling(of character: Character) -> [Character]? {
        if Self.keys.contains(character) { return [character] }
        
        guard let index = syllableIndex(of: character) else { return nil }
        
        return Array(
            Self.leading[index / Self.trailing.count / Self.vowels.count]
                + vowel(at: index)
                + trailing(at: index)
        )
    }
    
    // Whether the keyboard composes a jamo typed alone into the character before it: a
    // consonant into a syllable's final, a vowel into a syllable's or a jamo's.
    func joins(_ jamo: Character, after previous: Character) -> Bool {
        guard Self.keys.contains(jamo) else { return false }
        
        let isVowel = Self.vowels.contains(String(jamo))
        
        if let index = syllableIndex(of: previous) {
            let final = trailing(at: index)
            
            return isVowel
                ? !final.isEmpty || Self.vowels.contains(vowel(at: index) + String(jamo))
                : Self.trailing.contains(final + String(jamo))
        }
        
        return isVowel
            && (Self.leading.contains(String(previous)) || Self.vowels.contains(String(previous) + String(jamo)))
    }
    
    // MARK: - Private
    private func syllableIndex(of character: Character) -> Int? {
        guard let scalar = character.unicodeScalars.first,
            character.unicodeScalars.count == 1,
            Self.syllables.contains(scalar.value)
        else {
            return nil
        }
        
        return Int(scalar.value - Self.syllables.lowerBound)
    }
    
    private func vowel(at index: Int) -> String {
        Self.vowels[index / Self.trailing.count % Self.vowels.count]
    }
    
    private func trailing(at index: Int) -> String {
        Self.trailing[index % Self.trailing.count]
    }
}

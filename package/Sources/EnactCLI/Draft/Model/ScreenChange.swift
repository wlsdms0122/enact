//
//  ScreenChange.swift
//  EnactCLI
//
//  Created by JSilver on 11/10/26.
//

import Digit
import Enact
import Foundation

// What a screen newly shows after something was done to it: the elements of
// the look after that no element of the look before showed, by role and by
// the text `displayed_text` reads, leaving out the keyboard.
struct ScreenChange {
    // MARK: - Property
    // The roles a wait for the next screen catches, the likeliest to stand for
    // that screen first.
    private static let tiers: [Set<Role>] = [[.heading], [.field, .secureField, .button], [.text]]
    
    private let shown: [ObservedElement]
    
    private let after: ObservedScreen
    
    // MARK: - Initializer
    init(from before: ObservedScreen, to after: ObservedScreen) {
        let keyboard = Self.keyboardTop(of: after)
        
        self.shown = after.elements.filter { element in
            guard !element.text.isEmpty, element.snapshot.role != .key else { return false }
            guard keyboard.map({ top in element.snapshot.frame.center.y < top }) ?? true else { return false }
            
            return !before.elements.contains { seen in
                seen.snapshot.role == element.snapshot.role && seen.text == element.text
            }
        }
        self.after = after
    }
    
    // MARK: - Public
    // The element a wait for the screen after catches: the first tier that
    // has one, and in it one whose text the screen shows once, then the first
    // in reading order.
    var awaited: ObservedElement? {
        for roles in Self.tiers {
            let candidates = shown.filter { element in roles.contains(element.snapshot.role) }
            
            if let once = candidates.first(where: { element in after.elements.count { seen in seen.text == element.text } == 1 }) {
                return once
            }
            
            if let first = candidates.first { return first }
        }
        
        return nil
    }
    
    // MARK: - Private
    // Where the keyboard starts: one key row above its topmost key, which
    // takes in the row of predicted words above the keys, nil where it does
    // not show.
    private static func keyboardTop(of screen: ObservedScreen) -> Double? {
        let topmost = screen.elements
            .filter { element in element.snapshot.role == .key }
            .map(\.snapshot.frame)
            .min { one, other in one.y < other.y }
        
        return topmost.map { frame in frame.y - frame.height }
    }
}

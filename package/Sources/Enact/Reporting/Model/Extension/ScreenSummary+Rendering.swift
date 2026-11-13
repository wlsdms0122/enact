//
//  ScreenSummary+Rendering.swift
//  Enact
//
//  Created by JSilver on 11/13/26.
//

import Foundation

extension ScreenSummary {
    // The summary on one line, a few texts of each role and how many more.
    var line: String {
        let parts = [("heading", headings), ("button", buttons), ("field", fields)].compactMap { role, texts -> String? in
            guard !texts.isEmpty else { return nil }
            
            let shown = texts.prefix(Self.shown).map { text in "'\(text)'" }.joined(separator: ", ")
            let more = texts.count > Self.shown ? " +\(texts.count - Self.shown)" : ""
            
            return "\(role) \(shown)\(more)"
        }
        
        return parts.isEmpty ? "nothing named" : parts.joined(separator: " · ")
    }
    
    private static let shown = 5
}

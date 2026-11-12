//
//  TerminalTable.swift
//  DigitCLI
//
//  Created by JSilver on 8/16/26.
//

import Foundation

struct TerminalTable {
    // MARK: - Property
    // MARK: - Initializer
    // MARK: - Public
    func render(_ rows: [[String]]) -> String {
        guard let first = rows.first else { return "" }
        
        let widths = (0..<first.count).map { column in
            rows.map { $0.count > column ? width(of: $0[column]) : 0 }.max() ?? 0
        }
        
        return rows.map { row in
            row.enumerated()
                .map { index, cell in
                    index == row.count - 1 ? cell : padded(cell, to: widths[index])
                }
                .joined(separator: "  ")
                .trimmingCharacters(in: .whitespaces)
        }.joined(separator: "\n")
    }
    
    func width(of text: String) -> Int {
        text.unicodeScalars.reduce(0) { width, scalar in
            switch scalar.value {
            case 0x1100...0x115F, 0x2E80...0xA4CF, 0xAC00...0xD7A3,
                0xF900...0xFAFF, 0xFE30...0xFE6F, 0xFF00...0xFF60,
                0xFFE0...0xFFE6, 0x20000...0x3FFFD:
                return width + 2
            
            default:
                return width + 1
            }
        }
    }
    
    func padded(_ text: String, to width: Int) -> String {
        text + String(repeating: " ", count: max(0, width - self.width(of: text)))
    }
    
    // MARK: - Private
}

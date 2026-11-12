//
//  Report+Rendering.swift
//  Enact
//
//  Created by JSilver on 8/16/26.
//

import Foundation

extension Report {
    public var plain: String {
        var lines = [[scenario, device, outcome.rawValue, "\(durationMs)ms"]
            .joined(separator: "  ")]
        
        if let refused {
            lines.append("  refused: \(refused.rawValue): \(detail ?? "")")
        } else if let detail {
            lines.append("  \(detail)")
        }
        
        if let stop {
            lines.append(
                "  stop-at: \(stop.at), \(stop.reached ? "reached" : "never reached")"
            )
        }
        
        lines += steps.flatMap { $0.lines(indent: 1) }
        
        if !failures.isEmpty {
            lines.append("")
            lines.append("  failures: " + failures.joined(separator: ", "))
        }
        
        if let result, result.value != .null {
            lines.append("")
            lines.append("  returned  \(result.summary)")
        }
        
        if !recordings.isEmpty {
            lines.append("")
            lines += recordings.map { "  recorded  \($0)" }
        }
        
        if !lostRecordings.isEmpty {
            lines.append("")
            lines += lostRecordings.map { lost in "  lost      \(lost.path): \(lost.reason)" }
        }
        
        if let reportPath {
            lines.append("")
            lines.append("  report    \(reportPath)")
        }
        
        return lines.joined(separator: "\n")
    }
    
    public func json() throws -> String {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.sortedKeys, .withoutEscapingSlashes]
        
        return String(decoding: try encoder.encode(self), as: UTF8.self)
    }
}

extension StepReport {
    func lines(indent: Int) -> [String] {
        let pad = String(repeating: "  ", count: indent)
        let mark = switch status {
        case .running:
            "…"
        
        case .ok:
            "✓"
        
        case .failed:
            "✗"
        }
        
        var line = "\(pad)\(mark) \(id.padding(toLength: max(id.count, 18), withPad: " ", startingAt: 0))"
            + "  \(kind ?? "value")  \(ms)ms"
        
        if let failure { line += "  \(failure.kind.rawValue): \(failure.detail)" }
        
        var lines = [line]
        
        if let returned { lines.append("\(pad)    returned  \(returned.summary)") }
        if rescued == true { lines.append("\(pad)    rescued") }
        
        if let evidence {
            for (name, path) in [("screenshot", evidence.screenshot), ("tree", evidence.tree)] {
                if let path { lines.append("\(pad)    \(name)  \(path)") }
            }
        }
        
        lines += (steps ?? []).flatMap { $0.lines(indent: indent + 1) }
        
        for round in rounds ?? [] {
            lines.append("\(pad)    round \(round.index)")
            lines += round.steps.flatMap { $0.lines(indent: indent + 2) }
        }
        
        return lines
    }
}

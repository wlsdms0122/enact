//
//  AppContainerReader.swift
//  Digit
//
//  Created by JSilver on 8/16/26.
//

import Foundation

struct AppContainerReader {
    // MARK: - Property
    private let simctl = Simctl()
    
    // MARK: - Initializer
    // MARK: - Public
    func path(udid: String, bundleID: String, container: String) throws -> String {
        let asked = arguments(udid, bundleID, container)
        
        return try path(
            in: lines(of: try simctl.run(asked)),
            asked: asked,
            bundleID: bundleID,
            container: container
        )
    }
    
    func groups(udid: String, bundleID: String) throws -> [String: String] {
        let asked = arguments(udid, bundleID, "groups")
        
        return try groups(in: lines(of: try simctl.run(asked)), asked: asked)
    }
    
    func path(
        in lines: [String],
        asked: [String],
        bundleID: String,
        container: String
    ) throws -> String {
        guard !lines.isEmpty else {
            throw DigitError.noSuchContainer(bundleID: bundleID, container: container)
        }
        
        if let entry = lines.first(where: { $0.contains("\t") }) {
            throw unreadable(asked, "a listing entry rather than a path: \(entry)")
        }
        
        guard lines.count == 1 else {
            throw unreadable(asked, "\(lines.count) paths, and we asked for one")
        }
        
        guard lines[0] != "(null)" else {
            throw DigitError.noSuchContainer(bundleID: bundleID, container: container)
        }
        
        return lines[0]
    }
    
    func groups(in lines: [String], asked: [String]) throws -> [String: String] {
        var found: [String: String] = [:]
        
        for line in lines {
            let parts = line.split(separator: "\t", maxSplits: 1)
            
            guard parts.count == 2 else {
                throw unreadable(asked, "line is not a pair: \(line)")
            }
            
            guard found.updateValue(String(parts[1]), forKey: String(parts[0])) == nil else {
                throw unreadable(asked, "group listed twice: \(parts[0])")
            }
        }
        
        return found
    }
    
    func lines(of output: String) -> [String] {
        output.split(whereSeparator: \.isNewline)
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }
    }
    
    func arguments(_ udid: String, _ bundleID: String, _ container: String) -> [String] {
        ["get_app_container", udid, bundleID, container]
    }
    
    // MARK: - Private
    private func unreadable(_ asked: [String], _ reason: String) -> DigitError {
        .unreadableOutput(of: "simctl " + asked.joined(separator: " "), reason: reason)
    }
}

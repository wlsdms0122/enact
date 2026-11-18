//
//  OutputDirectory.swift
//  EnactWarp
//
//  Created by JSilver on 8/16/26.
//

import Foundation

// Where a run's artifacts land. A name is a single file name, and a name
// already taken gets a counter, so two writes never land on one file.
package struct OutputDirectory: Sendable {
    // MARK: - Property
    let url: URL
    
    // MARK: - Initializer
    package init(url: URL) {
        self.url = url
    }
    
    // MARK: - Public
    // A write that fails, or whose result says it kept nothing, leaves no
    // empty file behind.
    package func write<Result>(
        _ name: String,
        ext: String,
        kept: (Result) -> Bool = { _ in true },
        _ body: (URL) async throws -> Result
    ) async throws -> Result {
        let destination = try reserve(name, ext: ext)
        let result: Result
        
        do {
            result = try await body(destination)
        } catch {
            forfeit(destination)
            
            throw error
        }
        
        if !kept(result) { forfeit(destination) }
        
        return result
    }
    
    // MARK: - Private
    private func reserve(_ name: String, ext: String) throws -> URL {
        let stem = name.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !stem.isEmpty, stem != ".", stem != "..", !stem.contains("/"), !stem.contains("\u{0}") else {
            throw StepFailure(
                .argumentRefused,
                "'\(name)' is not a file name: an artifact lands in --out-dir under a single file name"
            )
        }
        
        try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
        
        var taken = 0
        
        while true {
            let candidate = taken == 0 ? "\(stem).\(ext)" : "\(stem)-\(taken).\(ext)"
            let destination = url.appendingPathComponent(candidate)
            let descriptor = open(destination.path, O_CREAT | O_EXCL | O_WRONLY, 0o644)
            
            if descriptor >= 0 {
                close(descriptor)
                
                return destination
            }
            
            guard errno == EEXIST else {
                throw StepFailure(
                    .deviceRefused,
                    "cannot reserve '\(candidate)' in --out-dir: \(String(cString: strerror(errno)))"
                )
            }
            
            taken += 1
        }
    }
    
    private func forfeit(_ destination: URL) {
        guard let attributes = try? FileManager.default.attributesOfItem(atPath: destination.path),
            (attributes[.size] as? Int) == 0
        else { return }
        
        try? FileManager.default.removeItem(at: destination)
    }
}

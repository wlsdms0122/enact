//
//  SearchPathStore.swift
//  Enact
//
//  Created by JSilver on 8/16/26.
//

import EnactWarp
import Foundation

// The scenarios in the files under each root, in folders at any depth, each
// found under the name its text declares. A folder is the author's
// arrangement and names nothing.
public struct SearchPathStore: ScenarioStore {
    // MARK: - Property
    let roots: [URL]
    
    // MARK: - Initializer
    public init(roots: [URL]) {
        self.roots = roots
    }
    
    // MARK: - Public
    public func sources() throws -> [ScenarioSource] {
        var seen: Set<String> = []
        
        return try roots.flatMap(Self.sources(under:)).filter { source in seen.insert(source.location).inserted }
    }
    
    // MARK: - Private
    // A hidden file or folder is not the author's scenario, so the search
    // does not go into one, and a file that does not read is no text.
    private static func sources(under root: URL) throws -> [ScenarioSource] {
        var isDirectory: ObjCBool = false
        
        guard FileManager.default.fileExists(atPath: root.path, isDirectory: &isDirectory), isDirectory.boolValue,
              let found = FileManager.default.enumerator(atPath: root.path) else {
            throw ScenarioLookupError.noDirectory(path: root.relativePath)
        }
        
        var files: [String] = []
        
        while let file = found.nextObject() as? String {
            if URL(fileURLWithPath: file).lastPathComponent.hasPrefix(".") {
                found.skipDescendants()
            } else if file.hasSuffix(".yaml") || file.hasSuffix(".yml") {
                files.append(file)
            }
        }
        
        return files.sorted().compactMap { file in
            let url = root.appendingPathComponent(file)
            guard let text = try? String(contentsOf: url, encoding: .utf8) else { return nil }
            
            return ScenarioSource(name: ScenarioHeader(text).module, file: url.relativePath, text: text)
        }
    }
}

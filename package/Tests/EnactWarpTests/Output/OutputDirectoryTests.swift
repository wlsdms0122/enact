//
//  OutputDirectoryTests.swift
//  EnactWarpTests
//
//  Created by JSilver on 10/31/26.
//

import Foundation
import Testing
@testable import EnactWarp

@Suite("An out dir keeps every artifact under a name of its own")
struct OutputDirectoryTests {
    private struct WriteFailed: Error {}
    
    // MARK: - Property
    private let directory: URL
    private let sut: OutputDirectory
    
    // MARK: - Initializer
    init() {
        directory = URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true)
            .appendingPathComponent("enact-out-\(UUID().uuidString)", isDirectory: true)
        sut = OutputDirectory(url: directory)
    }
    
    // MARK: - Test
    @Test("a write that fails leaves no empty file behind, and its name is free again")
    func aFailedWriteLeavesNothing() async throws {
        defer { try? FileManager.default.removeItem(at: directory) }
        
        // When
        await #expect(throws: WriteFailed.self) {
            _ = try await sut.write("shot", ext: "png") { _ in throw WriteFailed() }
        }
        
        // Then
        let written = try await sut.write("shot", ext: "png") { destination in
            try Data("png".utf8).write(to: destination)
            
            return destination
        }
        
        #expect(written.lastPathComponent == "shot.png")
    }
    
    @Test("a write whose result says it kept nothing leaves no empty file behind, and one it filled stays")
    func aWriteThatKeptNothingLeavesNothing() async throws {
        defer { try? FileManager.default.removeItem(at: directory) }
        
        // When
        let empty = try await sut.write("video", ext: "mp4", kept: { _ in false }) { destination in destination }
        let filled = try await sut.write("part", ext: "mp4", kept: { _ in false }) { destination in
            try Data("part".utf8).write(to: destination)
            
            return destination
        }
        
        // Then
        #expect(!FileManager.default.fileExists(atPath: empty.path))
        #expect(FileManager.default.fileExists(atPath: filled.path))
    }
    
    // MARK: - Private
}

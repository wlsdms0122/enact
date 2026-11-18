//
//  StandardInput.swift
//  DigitCLI
//
//  Created by JSilver on 8/16/26.
//

import ArgumentParser
import Foundation

public struct StandardInput: Sendable {
    // MARK: - Property
    // Standard input a session reads as its lines, which nothing else may read.
    static let taken = StandardInput(handle: nil)
    
    private let handle: FileHandle?
    
    // MARK: - Initializer
    public init() {
        self.init(handle: .standardInput)
    }
    
    private init(handle: FileHandle?) {
        self.handle = handle
    }
    
    // MARK: - Public
    public func text(as what: String) throws -> String {
        guard let handle else {
            throw ValidationError("standard input is this session's lines, so \(what) is written on the line, not read with -")
        }
        
        return try text(handle.readDataToEndOfFile(), as: what)
    }
    
    func text(_ data: Data, as what: String) throws -> String {
        guard let text = String(bytes: data, encoding: .utf8) else {
            throw ValidationError(
                "\(what) on standard input is not UTF-8 (\(data.count) bytes). "
                    + "Reading it anyway would replace the bad bytes and change what was sent"
            )
        }
        
        return text
    }
    
    // Each line without its newline and as bytes, so a line that is not UTF-8
    // is refused alone and the lines after it are still read.
    package func forEachLine(
        of handle: FileHandle = .standardInput,
        _ body: (Data) async -> Void
    ) async throws {
        var line = Data()
        
        for try await byte in handle.bytes {
            guard byte != UInt8(ascii: "\n") else {
                await body(line)
                line.removeAll()
                continue
            }
            
            line.append(byte)
        }
        
        if !line.isEmpty { await body(line) }
    }
    
    // MARK: - Private
}

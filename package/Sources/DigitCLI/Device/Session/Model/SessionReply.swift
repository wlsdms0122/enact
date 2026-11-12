//
//  SessionReply.swift
//  DigitCLI
//
//  Created by JSilver on 11/10/26.
//

import Foundation

package enum SessionReply: Encodable, Sendable {
    case result(any Encodable & Sendable)
    case error(SessionFailure)
    
    private enum CodingKeys: String, CodingKey {
        case result
        case error
    }
    
    // MARK: - Property
    // MARK: - Initializer
    // MARK: - Public
    package func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        switch self {
        case let .result(value):
            try container.encode(value, forKey: .result)
        case let .error(failure):
            try container.encode(failure, forKey: .error)
        }
    }
    
    // Written straight to the descriptor as one line, since whoever reads a
    // line is waiting for it and a buffered print would hold it back.
    package func write() {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.sortedKeys]
        
        do {
            try FileHandle.standardOutput.write(contentsOf: encoder.encode(self) + Data("\n".utf8))
        } catch {
            FileHandle.standardError.write(Data("enact: writing a reply: \(error)\n".utf8))
            Foundation.exit(EXIT_FAILURE)
        }
    }
    
    // MARK: - Private
}

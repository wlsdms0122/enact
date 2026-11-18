//
//  TestSupport.swift
//  EnactTests
//
//  Created by JSilver on 10/31/26.
//

import Foundation
import Warp
import WarpSyntax
@testable import Enact
@testable import EnactWarp

// The procedure a test scenario runs from.
let entry: Warp.Name = "main"

// A scenario of one public procedure, `main`, whose body is the lines given.
func scenarioFile(_ body: String) -> String {
    let procedure = body
        .split(separator: "\n", omittingEmptySubsequences: false)
        .drop { line in line.trimmingCharacters(in: .whitespaces).isEmpty }
        .map { line in line.isEmpty ? "" : "    \(line)" }
        .joined(separator: "\n")
    
    return """
    uses: [Enact]
    procedures:
      \(entry.spelling):
        access: public
    \(procedure)
    """
}

// Reads a scenario over the shipped vocabulary.
func document(of text: String) throws -> ScenarioDocument {
    let written = try EnactVocabulary.shipped.get().frontend().document(from: text)
    
    return try ScenarioDocument(try BinaryEncoding().value(from: written.document), origin: written.origin, file: "-")
}

// Reads and builds a scenario over the shipped vocabulary.
func image(of text: String) async throws -> Image {
    try await ScenarioBuilder.shipped.get().image(of: [try document(of: text).module])
}

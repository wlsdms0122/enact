//
//  TestSupport.swift
//  EnactWarpTests
//
//  Created by JSilver on 10/31/26.
//

import Foundation
import Warp
import WarpSyntax
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

// The shipped vocabulary, compiled once and laid down for a scenario to
// compile against.
let shippedBuild = Task {
    let modules = try EnactVocabulary.shipped.get().linkables
    let supplying = try Supplying(modules)
    let compiled = try await Builder().compile(modules, against: [], supplying: supplying)
    
    return (compiled: compiled, laid: try Builder().lay(compiled, supplying: supplying), supplying: supplying)
}

// Reads and builds a scenario over the shipped vocabulary.
func image(of text: String) async throws -> Image {
    let frontend = try EnactVocabulary.shipped.get().frontend()
    let module = try Loader().load(try BinaryEncoding().value(from: try frontend.document(from: text).document))
    let vocabulary = try await shippedBuild.value
    let compiled = try await Builder().compile([module], against: vocabulary.laid)
    
    return try Builder().link(vocabulary.compiled + compiled, supplying: vocabulary.supplying)
}

// Reads, builds and runs a scenario over the shipped vocabulary.
func run(
    _ text: String,
    environment: (any Warp.Environment)? = nil
) async throws -> Warp.Value {
    try await Executor(environment: environment).run(try await image(of: text), entry: entry)
}

// An `Enact.Snapshot` as a scenario writes one, of a frame given as x, y,
// width and height.
func snapshotLiteral(
    role: String = "button",
    label: String? = "Save",
    value: String? = nil,
    frame: (Double, Double, Double, Double) = (100, 200, 80, 40),
    track: (Double, Double, Double, Double)? = nil,
    indexPath: [Int] = [],
    enabled: Bool = true
) -> String {
    func written(_ frame: (Double, Double, Double, Double)) -> String {
        "{ struct: { x: \(frame.0), y: \(frame.1), width: \(frame.2), height: \(frame.3) } }"
    }
    
    let label = label.map { label in "\"\(label)\"" } ?? "null"
    let value = value.map { value in "\"\(value)\"" } ?? "null"
    let track = track.map(written) ?? "null"
    
    return "{ struct: { id: null, label: \(label), value: \(value), role: { case: { \(role): {} } }, enabled: \(enabled), actions: [], "
        + "frame: \(written(frame)), track: \(track), index_path: \(indexPath) } }"
}

// A scenario that calls one verb and returns what it returns.
func verbCall(_ procedure: String, _ arguments: String? = nil, returns: String? = nil) -> String {
    scenarioFile("""
    \(returns.map { type in "returns: \(type)" } ?? "")
    failing: anything
    result: { call: { procedure: \(procedure)\(arguments.map { written in ", arguments: \(written)" } ?? "") } }
    """)
}

//
//  Eval.swift
//  EnactCLI
//
//  Created by JSilver on 11/13/26.
//

import ArgumentParser
import Enact
import Foundation

struct Eval: AsyncParsableCommand {
    // MARK: - Property
    static let configuration = CommandConfiguration(
        commandName: "eval",
        abstract: "Answer a query of a screen against a look written down, with no device.",
        discussion: """
            The query is a public, const and isolated procedure of one \
            Enact.Screen, named as Module.procedure and found in --path with \
            every scenario it calls. The look is the JSON a failure leaves in \
            --out-dir beside its screenshot. Prints what the query returns, as \
            JSON.
            """
    )
    
    @Argument(help: "The query, as Module.procedure.")
    var query: String
    
    @Option(name: .customLong("path"), help: "A directory scenarios are found in, at any depth. Repeatable.")
    var paths: [String] = []
    
    @Option(name: .customLong("look"), help: "A look written down, as a failure leaves one.")
    var look: String
    
    // MARK: - Initializer
    // MARK: - Public
    func validate() throws {
        guard !paths.isEmpty else { throw ValidationError("a query is found in --path") }
    }
    
    func run() async throws {
        do {
            let engine = try Engine()
            let found = try await engine.query(
                query,
                store: SearchPathStore(roots: paths.map { path in URL(fileURLWithPath: path, isDirectory: true) })
            )
            
            print(try await engine.answer(found, of: try Data(contentsOf: URL(fileURLWithPath: look))))
        } catch {
            print("\(error)")
            
            throw ExitCode(1)
        }
    }
    
    // MARK: - Private
}

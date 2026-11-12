//
//  Graph.swift
//  EnactCLI
//
//  Created by JSilver on 8/16/26.
//

import ArgumentParser
import Enact
import Foundation

struct Graph: AsyncParsableCommand {
    // MARK: - Property
    static let configuration = CommandConfiguration(
        commandName: "graph",
        abstract: "Show what a scenario calls, and what it can ask a device to do.",
        discussion: """
            For a caller deciding whether to let a procedure run. It is not a \
            risk assessment and cannot be made into one: money moving is three \
            taps, and no list of operations will ever show that.
            """
    )
    
    @OptionGroup var scenario: ScenarioOption
    
    // MARK: - Initializer
    // MARK: - Public
    func run() async throws {
        let built: Scenario
        
        do {
            let entry = try scenario.entry()
            
            built = try await Engine().check(entry.name, store: entry.store)
        } catch {
            print("\(error)")
            
            throw ExitCode(1)
        }
        
        for entry in built.graph {
            print(entry.scenario)
            
            if !entry.calls.isEmpty { print("  calls  \(entry.calls.joined(separator: ", "))") }
            if !entry.verbs.isEmpty { print("  does   \(entry.verbs.joined(separator: ", "))") }
        }
    }
    
    // MARK: - Private
}

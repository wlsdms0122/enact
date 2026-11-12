//
//  Check.swift
//  EnactCLI
//
//  Created by JSilver on 8/16/26.
//

import ArgumentParser
import Enact
import Foundation

struct Check: AsyncParsableCommand {
    // MARK: - Property
    static let configuration = CommandConfiguration(
        commandName: "check",
        abstract: "Read and build a scenario and say whether it can be run at all.",
        discussion: """
            The same reading and building a run does first, not a second \
            checker, which would drift from the first. A scenario with no \
            public main is checked as a module the others call, which a run \
            refuses.
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
        
        print("\(built.name)  ok")
        print("  scenarios  \(built.scenarios.joined(separator: ", "))")
        
        if built.entry == nil {
            print("  main       none, so it builds for the scenarios that call it and a run refuses it")
        }
    }
    
    // MARK: - Private
}

//
//  RepeatAction.swift
//  EnactWarp
//
//  Created by JSilver on 10/31/26.
//

import Foundation
import Warp

// Runs its body round after round until what a round returns is what until
// waits for, and returns it. With debounce, what until took must also come
// back the same for that many seconds. Out of time, it is timed_out.
struct RepeatAction: Warp.Effect {
    enum Parameters: Int, ParameterSet {
        case timeout
        case debounce
        case body
        case until
        
        // MARK: - Property
        var declared: Parameter {
            switch self {
            case .timeout:
                Parameter(name: "timeout")
            
            case .debounce:
                Parameter(name: "debounce")
            
            case .body:
                Parameter(name: "body")
            
            case .until:
                Parameter(name: "until")
            }
        }
        
        // MARK: - Initializer
        // MARK: - Public
        // MARK: - Private
    }
    
    // MARK: - Property
    // The pause between one round and the next.
    private static let cadence: Duration = .milliseconds(200)
    
    // MARK: - Initializer
    // MARK: - Public
    func run(_ invocation: Invocation<Self>) async throws -> Warp.Value {
        guard case let .procedure(body) = invocation[.body], case let .procedure(until) = invocation[.until] else {
            throw RunRefused("'\(invocation.selector)' was handed no procedure for body or until")
        }
        
        let timeout = try invocation.seconds(.timeout)
        let debounce = invocation[.debounce] == .null ? nil : try invocation.seconds(.debounce)
        
        guard timeout > 0 else {
            throw StepFailure(.argumentRefused, "timeout is \(timeout), the seconds repeat may spend")
        }
        
        if let debounce, debounce <= 0 {
            throw StepFailure(.argumentRefused, "debounce is \(debounce), the seconds a result holds still")
        }
        
        let clock = ContinuousClock()
        let deadline = clock.now + .seconds(timeout)
        var round = 0
        var heldOnce = false
        var stable: (since: ContinuousClock.Instant, value: Warp.Value)?
        
        while true {
            let produced = try await invocation.call(body, piece: "\(round)")
            let holds = try await invocation.call(until, handing: [produced], piece: "\(round)") == .bool(true)
            
            if holds {
                heldOnce = true
                
                guard let debounce else { return produced }
                
                if let seen = stable, seen.value == produced {
                    if clock.now - seen.since >= .seconds(debounce) { return produced }
                } else {
                    stable = (since: clock.now, value: produced)
                }
            } else {
                stable = nil
            }
            
            guard clock.now < deadline else {
                throw StepFailure(
                    .timedOut,
                    heldOnce ? "it held, but never held still for \(debounce ?? 0)s" : "\(timeout)s spent, and it never held"
                )
            }
            
            round += 1
            try await Task.sleep(for: Self.cadence)
        }
    }
    
    // MARK: - Private
}

//
//  KeyboardGraph.swift
//  Digit
//
//  Created by JSilver on 11/10/26.
//

import Foundation

// The layers of the software keyboards seen so far, and where tapping a control key on
// each was seen to lead.
struct KeyboardGraph {
    // MARK: - Property
    private static let controls: [SoftwareKey] = [.shift, .more, .nextKeyboard]
    
    // The keyboards Next keyboard has named, in the order seen.
    private(set) var keyboards: [String] = []
    
    private var states: Set<KeyboardState> = []
    private var edges: [KeyboardState: [SoftwareKey: KeyboardState]] = [:]
    
    // MARK: - Initializer
    // MARK: - Public
    mutating func visit(_ state: KeyboardState) {
        states.insert(state)
        
        if let keyboard = state.nextKeyboard, !keyboards.contains(keyboard) {
            keyboards.append(keyboard)
        }
    }
    
    // A tap is recorded as where it led last, as what a tap does can follow the text typed.
    mutating func record(_ control: SoftwareKey, from state: KeyboardState, to next: KeyboardState) {
        edges[state, default: [:]][control] = next
        
        visit(next)
    }
    
    func contains(_ key: SoftwareKey) -> Bool {
        contains { seen in seen == key }
    }
    
    func contains(where matches: (SoftwareKey) -> Bool) -> Bool {
        states.contains { state in state.keys.contains(where: matches) }
    }
    
    // The keyboards seen to have `key`, each told by what its Next keyboard names.
    func keyboards(having key: SoftwareKey) -> Set<String?> {
        Set(states.filter { state in state.keys.contains(key) }.map(\.nextKeyboard))
    }
    
    // The control to tap next on the way from `start` to a layer `reached` holds of: along
    // taps seen to lead there, or else toward the nearest layer where the control
    // `preferred` names for it is not tapped yet, or else toward the nearest control not
    // tapped yet. Nil when `start` is one, or when every control seen from it has been
    // tapped and none led to one.
    func step(
        from start: KeyboardState,
        toward reached: (KeyboardState) -> Bool,
        preferring preferred: (KeyboardState) -> SoftwareKey? = { _ in nil }
    ) -> SoftwareKey? {
        if let route = route(from: start, to: reached) { return route.taps.first }
        
        if let route = route(from: start, to: { state in untapped(preferred, on: state) != nil }) {
            return route.taps.first ?? untapped(preferred, on: route.end)
        }
        
        guard let route = route(from: start, to: { state in untapped(on: state) != nil }) else {
            return nil
        }
        
        return route.taps.first ?? untapped(on: route.end)
    }
    
    // MARK: - Private
    // The route of the fewest Next keyboard taps, then of the fewest taps, as switching
    // keyboards takes the time of several taps.
    private func route(
        from start: KeyboardState,
        to reached: (KeyboardState) -> Bool
    ) -> (end: KeyboardState, taps: [SoftwareKey])? {
        var queue: [(end: KeyboardState, taps: [SoftwareKey])] = [(start, [])]
        var settled: Set<KeyboardState> = []
        
        while let index = queue.indices.min(by: { lhs, rhs in cost(of: queue[lhs].taps) < cost(of: queue[rhs].taps) }) {
            let route = queue.remove(at: index)
            
            guard settled.insert(route.end).inserted else { continue }
            
            if reached(route.end) { return route }
            
            for control in Self.controls {
                guard let next = edges[route.end]?[control], !settled.contains(next) else { continue }
                
                queue.append((next, route.taps + [control]))
            }
        }
        
        return nil
    }
    
    private func cost(of taps: [SoftwareKey]) -> (switches: Int, taps: Int) {
        (taps.filter { tap in tap == .nextKeyboard }.count, taps.count)
    }
    
    private func untapped(on state: KeyboardState) -> SoftwareKey? {
        Self.controls.first { control in isUntapped(control, on: state) }
    }
    
    private func untapped(
        _ preferred: (KeyboardState) -> SoftwareKey?,
        on state: KeyboardState
    ) -> SoftwareKey? {
        preferred(state).flatMap { control in isUntapped(control, on: state) ? control : nil }
    }
    
    private func isUntapped(_ control: SoftwareKey, on state: KeyboardState) -> Bool {
        state.keys.contains(control) && edges[state]?[control] == nil
    }
}

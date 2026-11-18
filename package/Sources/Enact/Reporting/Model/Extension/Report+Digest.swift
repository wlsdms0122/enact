//
//  Report+Digest.swift
//  Enact
//
//  Created by JSilver on 8/16/26.
//

extension Report {
    public var digest: Report {
        var short = self
        short.steps = steps.compactMap { $0.digested }
        
        return short
    }
}

extension StepReport {
    var digested: StepReport? {
        let inside = (steps ?? []).compactMap { $0.digested }
        let passes = (rounds ?? []).compactMap { round -> Round? in
            let steps = round.steps.compactMap { $0.digested }
            
            return steps.isEmpty ? nil : Round(index: round.index, steps: steps)
        }
        
        guard status == .failed || !inside.isEmpty || !passes.isEmpty else {
            return nil
        }
        
        var kept = self
        kept.steps = inside.isEmpty ? nil : inside
        kept.rounds = passes.isEmpty ? nil : passes
        
        return kept
    }
}

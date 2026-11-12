//
//  Journal.swift
//  Enact
//
//  Created by JSilver on 8/16/26.
//

import EnactWarp
import Foundation
import Warp

// What a run did, statement by statement, as the scenario wrote it. A
// statement is the scenario's when the body it stands in is: a procedure or a
// closure the scenario declared, so a verb's own statements in the library
// stay out. One statement holds the scenario statements that ran under it,
// through the verbs and procedures it called, and a round of a repeat or a
// loop holds its own. A failure is charged to the statement it happened in,
// not to each one it passed through, and a catch gives the charge back while
// the record stays.
public final class Journal: ExecutionObserver, @unchecked Sendable {
    private struct Open {
        // MARK: - Property
        var report: StepReport
        let address: StatementAddress
        let trace: Trace
        let round: Int?
        let chargeMark: Int
        let began = Date()
        var children: [StepReport] = []
        var rounds: [Int: [StepReport]] = [:]
        
        // MARK: - Initializer
        // MARK: - Public
        // MARK: - Private
    }
    
    public struct Event: Sendable, Encodable {
        // MARK: - Property
        public let event: String
        public var scenario: String? = nil
        public var device: String? = nil
        public var path: String? = nil
        public var kind: String? = nil
        public var status: String? = nil
        public var ms: Int? = nil
        public var failure: StepFailure? = nil
        public var rescued: Bool? = nil
        public var outcome: String? = nil
        public var failures: [String]? = nil
        public var durationMs: Int? = nil
        public var detail: String? = nil
        public var refused: String? = nil
        
        // MARK: - Initializer
        // MARK: - Public
        public func json() throws -> String {
            let encoder = JSONEncoder()
            encoder.outputFormatting = [.sortedKeys, .withoutEscapingSlashes]
            
            return String(decoding: try encoder.encode(self), as: UTF8.self)
        }
        
        // MARK: - Private
    }
    
    public typealias Sink = @Sendable (Event) -> Void
    typealias Evidence = @Sendable (String) async -> StepReport.Evidence?
    
    // MARK: - Property
    let scenario: String
    let device: String
    
    var reachedStop: Bool { lock.withLock { stopped } }
    var failures: [String] { lock.withLock { charged } }
    
    private let vocabulary: Set<String>
    private let enums: Set<Warp.Name>
    private let sink: Sink?
    private let lock = NSLock()
    private var evidence: Evidence?
    private var stopAt: StatementAddress?
    private var onStop: (@Sendable () -> Void)?
    private var started = Date()
    private var stopped = false
    private var charged: [String] = []
    private var open: [Open] = []
    private var root: [StepReport] = []
    
    // MARK: - Initializer
    // The vocabulary is every procedure the scenario did not write, and the
    // enums every type the image declares as one.
    init(scenario: String, device: String, vocabulary: Set<String>, enums: Set<Warp.Name>, sink: Sink? = nil) {
        self.scenario = scenario
        self.device = device
        self.vocabulary = vocabulary
        self.enums = enums
        self.sink = sink
    }
    
    // MARK: - Lifecycle
    public func statementStarted(at trace: Trace) async {
        lock.withLock {
            settle(under: trace)
            name(trace)
            
            guard isScenarios(trace) else { return }
            
            let parent = open.last
            let id = trace.hops.last.map(Self.label) ?? ""
            let address = (parent?.address ?? StatementAddress()).appending(id)
            let report = StepReport(id: id, path: address.description)
            
            open.append(
                Open(
                    report: report,
                    address: address,
                    trace: trace,
                    round: round(of: trace, under: parent?.trace),
                    chargeMark: charged.count
                )
            )
            emit(Event(event: "step_begin", path: report.path))
        }
    }
    
    public func statementCompleted(at trace: Trace, result: Value) async {
        let stop: (@Sendable () -> Void)? = lock.withLock {
            guard isScenarios(trace), settle(to: trace), var finished = open.popLast() else { return nil }
            
            if finished.report.status == .running { finished.report.status = .ok }
            if result != .null { finished.report.returned = ReportedValue(result, enums: enums) }
            
            let address = finished.address
            
            file(finished)
            
            guard address == stopAt, !stopped else { return nil }
            
            stopped = true
            
            return onStop
        }
        
        stop?()
    }
    
    public func statementFailed(at trace: Trace, error: any Error) async {
        let failure = StepFailure(failing: error)
        let blamed: String? = lock.withLock {
            guard isScenarios(trace), settle(to: trace), !open.isEmpty else { return nil }
            
            // A stop this run asked for ends it with an interruption that is no failure.
            guard !(stopped && failure.kind == .interrupted) else {
                file(open.removeLast())
                
                return nil
            }
            
            let last = open.count - 1
            let address = open[last].report.path
            let innermost = charged.count == open[last].chargeMark
            
            open[last].report.status = .failed
            open[last].report.failure = failure
            
            if innermost { charged.append(address) }
            
            guard innermost, failure.kind != .interrupted, evidence != nil else {
                file(open.removeLast())
                
                return nil
            }
            
            return address
        }
        
        guard let blamed else { return }
        
        let found = await evidence?(blamed)
        
        lock.withLock {
            guard let top = open.last, top.trace == trace else { return }
            
            var finished = open.removeLast()
            
            finished.report.evidence = found
            file(finished)
        }
    }
    
    public func failureCaught(name: String?, error: any Error) async {
        lock.withLock {
            guard !open.isEmpty else { return }
            
            open[open.count - 1].report.rescued = true
            
            let mark = open[open.count - 1].chargeMark
            
            if mark < charged.count { charged.removeSubrange(mark...) }
        }
    }
    
    // MARK: - Public
    func bound(at address: StatementAddress?, evidence: Evidence?, _ stop: @escaping @Sendable () -> Void) {
        lock.withLock {
            self.stopAt = address
            self.evidence = evidence
            self.onStop = stop
        }
    }
    
    func began() {
        lock.withLock {
            started = Date()
            emit(Event(event: "run_begin", scenario: scenario, device: device))
        }
    }
    
    func refuse(_ reason: Report.Refusal, _ detail: String) -> Report {
        emit(Event(
            event: "run_end",
            scenario: scenario,
            device: device,
            outcome: Report.Outcome.refused.rawValue,
            detail: detail,
            refused: reason.rawValue
        ))
        
        return .refusing(reason, detail, scenario: scenario, device: device)
    }
    
    func finish(
        outcome: Report.Outcome,
        detail: String?,
        result: Warp.Value?,
        recordings: [String],
        lostRecordings: [LostRecording] = [],
        stop: Report.Stop? = nil
    ) -> Report {
        lock.withLock {
            while let top = open.popLast() { file(top, left: true) }
            
            let duration = Int(Date().timeIntervalSince(started) * 1000)
            
            emit(Event(event: "run_end", outcome: outcome.rawValue, failures: charged, durationMs: duration, detail: detail))
            
            return Report(
                scenario: scenario,
                device: device,
                outcome: outcome,
                failures: charged,
                durationMs: duration,
                steps: root,
                result: result.map { value in ReportedValue(value, enums: enums) },
                recordings: recordings,
                lostRecordings: lostRecordings,
                detail: detail,
                stop: stop
            )
        }
    }
    
    // MARK: - Private
    private static func label(_ hop: Trace.Hop) -> String {
        guard case let .statement(name) = hop else { return "" }
        
        return name
    }
    
    // Whether a run at the inner trace is under the outer one.
    private static func holds(_ outer: Trace, _ inner: Trace) -> Bool {
        inner.hops.starts(with: outer.hops)
    }
    
    // Whether the statement stands in a body the scenario wrote: the entry's,
    // which a run starts in with no hop, or a procedure's or closure's the
    // vocabulary does not declare.
    private func isScenarios(_ trace: Trace) -> Bool {
        guard case .statement = trace.hops.last else { return false }
        
        for hop in trace.hops.reversed() {
            switch hop {
            case let .procedure(name), let .closure(of: name, _):
                return !vocabulary.contains(name)
            
            default:
                continue
            }
        }
        
        return true
    }
    
    // A statement run under a scenario statement names it by the procedure
    // that statement called.
    private func name(_ trace: Trace) {
        guard let index = open.lastIndex(where: { candidate in Self.holds(candidate.trace, trace) }),
            open[index].report.kind == nil,
            case let .procedure(called)? = trace.hops.dropFirst(open[index].trace.hops.count).first
        else { return }
        
        open[index].report.kind = called.split(separator: ".").last.map(String.init) ?? called
    }
    
    // The round a statement ran in under its parent: a loop's round or the
    // numbered piece a repeat called its body in.
    private func round(of trace: Trace, under parent: Trace?) -> Int? {
        trace.hops.dropFirst(parent?.hops.count ?? 0).dropLast().compactMap { hop -> Int? in
            switch hop {
            case let .round(index):
                index
            
            case let .piece(name):
                Int(name)
            
            default:
                nil
            }
        }.last
    }
    
    // Files the statements a return or a break left, which never finish.
    private func settle(under trace: Trace) {
        while let top = open.last, !Self.holds(top.trace, trace) {
            file(open.removeLast(), left: true)
        }
    }
    
    private func settle(to trace: Trace) -> Bool {
        guard open.contains(where: { candidate in candidate.trace == trace }) else { return false }
        
        while let top = open.last, top.trace != trace {
            file(open.removeLast(), left: true)
        }
        
        return true
    }
    
    // A statement left by a return that called nothing and held nothing is
    // the value a body returns, said by the statement that called the body.
    private func file(_ finished: Open, left: Bool = false) {
        var top = finished
        let said = left && top.report.kind == nil && top.children.isEmpty && top.rounds.isEmpty && top.report.status == .running
        
        top.report.ms = Int(Date().timeIntervalSince(top.began) * 1000)
        if top.report.status == .running { top.report.status = .ok }
        if !top.children.isEmpty { top.report.steps = top.children }
        if !top.rounds.isEmpty {
            top.report.rounds = top.rounds.keys.sorted().map { index in StepReport.Round(index: index, steps: top.rounds[index] ?? []) }
        }
        
        emit(Event(
            event: "step_end",
            path: top.report.path,
            kind: top.report.kind,
            status: top.report.status.rawValue,
            ms: top.report.ms,
            failure: top.report.failure,
            rescued: top.report.rescued
        ))
        
        guard !said else { return }
        
        guard !open.isEmpty else {
            root.append(top.report)
            
            return
        }
        
        if let round = top.round {
            open[open.count - 1].rounds[round, default: []].append(top.report)
        } else {
            open[open.count - 1].children.append(top.report)
        }
    }
    
    private func emit(_ event: Event) {
        sink?(event)
    }
}

//
//  Run.swift
//  EnactCLI
//
//  Created by JSilver on 8/16/26.
//

import ArgumentParser
import Digit
import DigitCLI
import Enact
import Foundation

struct Run: AsyncParsableCommand {
    // MARK: - Property
    static let configuration = CommandConfiguration(
        commandName: "run",
        abstract: "Carry out a scenario on a device.",
        discussion: """
            The device is held for the whole run: a scenario is one sequence, \
            and it is not one if someone else's tap can land in the middle of \
            it. A device already held is reported busy rather than waited for.
            
            Prints the report on every path: the outcome, the failures and \
            the statements they happened in. --verbose prints every step; --json \
            asks for either of those as JSON rather than the plain form. \
            --report leaves the whole record in --out-dir whatever is printed, \
            for a run that is worth reading again and cannot be repeated.
            
            Exits 0 when the run finished and nothing failed. That is this \
            command's reading of the report, not the engine's: what counts as \
            success depends on what the scenario is being used for, so the \
            engine reports and does not judge.
            """
    )
    
    @OptionGroup var scenario: ScenarioOption
    
    @Option(name: .customLong("udid"), help: "Target device, or 'booted'.")
    var udid: String = DeviceSet.bootedAlias
    
    @Option(name: .customLong("out-dir"), help: "Where screenshots, videos, logs and failure dumps land.")
    var outputDirectory: String = NSTemporaryDirectory() + "enact"
    
    @Option(
        name: .customLong("input"),
        parsing: .upToNextOption,
        help: "An input, as name=value. Repeatable."
    )
    var inputs: [Input] = []
    
    @Option(
        name: .customLong("stop-at"),
        help: "The last statement to carry out, by its address; the run ends there the first time it is reached."
    )
    var stopAt: String?
    
    @Flag(
        name: .customLong("stream"),
        help: "Emit journal events as NDJSON on stderr while the run goes."
    )
    var stream = false
    
    @Flag(
        name: .shortAndLong,
        help: "Print every statement, not only the failures and what they were inside."
    )
    var verbose = false
    
    @Flag(
        name: .customLong("report"),
        help: "Write the whole record to --out-dir as report.json."
    )
    var report = false
    
    @OptionGroup var output: OutputOption
    
    // MARK: - Initializer
    // MARK: - Public
    func run() async throws {
        let inputs = try Self.read(inputs)
        let signals = SignalWaiter([SIGINT, SIGTERM])
        defer { signals.disarm() }
        
        var events: Journal.Sink?
        
        if stream {
            signal(SIGPIPE, SIG_IGN)
            
            events = { event in
                let line = ((try? event.json()) ?? #"{"event":"unwritable"}"#) + "\n"
                let bytes = Array(line.utf8)
                
                bytes.withUnsafeBufferPointer { buffer in
                    var sent = 0
                    
                    while sent < buffer.count {
                        let wrote = write(
                            STDERR_FILENO,
                            buffer.baseAddress! + sent,
                            buffer.count - sent
                        )
                        
                        guard wrote > 0 else { return }
                        
                        sent += wrote
                    }
                }
            }
        }
        
        let entry = try scenario.entry()
        let engine = try Engine()
        let work = Task { [entry, udid, outputDirectory, stopAt, report] in
            await engine.run(
                entry.name,
                store: entry.store,
                udid: udid,
                inputs: inputs,
                outputDirectory: URL(fileURLWithPath: outputDirectory, isDirectory: true),
                stopAt: stopAt,
                events: events,
                record: report
            )
        }
        
        let onSignal = Task {
            await signals.wait()
            work.cancel()
        }
        defer { onSignal.cancel() }
        
        let done = await work.value
        
        if report, done.reportPath == nil {
            FileHandle.standardError.write(Data(
                "enact: --report: could not write the record to \(outputDirectory)\n".utf8
            ))
        }
        
        let shown = verbose ? done : done.digest
        
        print(output.json ? try shown.json() : shown.plain)
        
        if done.outcome != .completed || !done.failures.isEmpty { throw ExitCode(1) }
    }
    
    static func read(_ written: [Input]) throws -> [String: String] {
        try written.reduce(into: [:]) { given, one in
            guard given[one.name] == nil else {
                throw ArgumentParser.ValidationError("--input \(one.name): given more than once")
            }
            
            given[one.name] = one.text
        }
    }
    
    // MARK: - Private
}

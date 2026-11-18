//
//  SimctlTests.swift
//  DigitTests
//
//  Created by JSilver on 8/16/26.
//

import Foundation
import Testing
@testable import Digit

@Suite("A simctl exchange drains both streams and feeds input without deadlock")
struct SimctlTests {
    private final class Slot: @unchecked Sendable {
        var value: (printed: Data, complained: Data)?
        var thrown: Error?
    }
    
    // MARK: - Property
    private let sut = Simctl()
    
    // MARK: - Initializer
    // MARK: - Test
    @Test("a child filling stderr is drained while stdout is read")
    func aChildSpewingStderrIsDrained() {
        // Given
        let process = shell("head -c 1048576 /dev/zero | tr '\\0' e 1>&2; printf done")
        
        // When
        let result = converse(process, telling: nil)
        
        // Then
        #expect(result != nil, "deadlocked")
        #expect(String(decoding: result?.printed ?? Data(), as: UTF8.self) == "done")
        #expect(result?.complained.count == 1_048_576)
    }
    
    @Test("a child dying while being fed still answers")
    func aChildDyingMidFeedStillAnswers() {
        // Given
        let process = shell("echo boom 1>&2; exit 1")
        
        // When
        let result = converse(process, telling: String(repeating: "x", count: 1_048_576))
        
        // Then
        #expect(result != nil, "deadlocked")
        #expect(String(decoding: result?.complained ?? Data(), as: UTF8.self) == "boom\n")
        #expect(process.terminationStatus == 1)
    }
    
    @Test("stdin, stdout and stderr make progress independently")
    func theStreamsMakeIndependentProgress() {
        // Given
        let process = shell("head -c 1048576 /dev/zero | tr '\\0' e 1>&2; wc -c | tr -d ' '")
        
        // When
        let result = converse(process, telling: String(repeating: "x", count: 1_048_576))
        
        // Then
        #expect(result != nil, "deadlocked")
        #expect(String(decoding: result?.printed ?? Data(), as: UTF8.self) == "1048576\n")
        #expect(result?.complained.count == 1_048_576)
    }
    
    @Test("success over a feed the child refused is refused")
    func successOverABrokenFeedIsRefused() {
        // Given
        let process = shell("exit 0")
        let slot = Slot()
        let done = DispatchGroup()
        
        // When
        DispatchQueue.global().async(group: done) { [sut] in
            do {
                _ = try sut.exchange(process, telling: String(repeating: "x", count: 1_048_576))
            } catch {
                slot.thrown = error
            }
        }
        
        // Then
        #expect(done.wait(timeout: .now() + 10) == .success, "deadlocked")
        #expect("\(slot.thrown.map { "\($0)" } ?? "")".contains("refusing its input"))
    }
    
    // MARK: - Private
    private func shell(_ script: String) -> Process {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/bin/sh")
        process.arguments = ["-c", script]
        
        return process
    }
    
    private func converse(_ process: Process, telling input: String?) -> (printed: Data, complained: Data)? {
        let slot = Slot()
        let done = DispatchGroup()
        
        DispatchQueue.global().async(group: done) { [sut] in
            slot.value = try? sut.exchange(process, telling: input)
        }
        
        guard done.wait(timeout: .now() + 10) == .success else {
            process.terminate()
            
            return nil
        }
        
        return slot.value
    }
}

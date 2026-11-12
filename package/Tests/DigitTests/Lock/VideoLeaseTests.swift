//
//  VideoLeaseTests.swift
//  DigitTests
//
//  Created by JSilver on 8/16/26.
//

import Foundation
import Testing
@testable import Digit

@Suite("A video lease keeps an unclosed video from being followed by another")
struct VideoLeaseTests {
    private struct VideoStuck: Error {}
    private struct WorkFailed: Error {}
    
    private final class VideoBackend: DeviceBackend {
        // MARK: - Property
        let info = DeviceInfo(udid: "udid-video", name: "stub", osVersion: "iOS 26.0", state: .booted)
        
        var dispatchTable: DispatchTable {
            DispatchTable([.perform({ (_: RecordVideoOperator) in Recording {} })])
        }
        
        // MARK: - Initializer
        // MARK: - Public
        // MARK: - Private
    }
    
    private final class LoggableBackend: DeviceBackend {
        // MARK: - Property
        let info = DeviceInfo(udid: "udid-video", name: "stub", osVersion: "iOS 26.0", state: .booted)
        
        var dispatchTable: DispatchTable {
            DispatchTable([
                .perform({ (_: RecordVideoOperator) in Recording {} }),
                .perform({ (_: RecordLogOperator) in Recording {} })
            ])
        }
        
        // MARK: - Initializer
        // MARK: - Public
        // MARK: - Private
    }
    
    private final class DeafBackend: DeviceBackend {
        // MARK: - Property
        let info = DeviceInfo(udid: "udid-deaf", name: "stub", osVersion: "iOS 26.0", state: .booted)
        
        var dispatchTable: DispatchTable { DispatchTable([]) }
        
        // MARK: - Initializer
        // MARK: - Public
        // MARK: - Private
    }
    
    private final class UnstoppableBackend: DeviceBackend {
        // MARK: - Property
        let info = DeviceInfo(udid: "udid-video", name: "stub", osVersion: "iOS 26.0", state: .booted)
        
        var dispatchTable: DispatchTable {
            DispatchTable([
                .perform({ (_: RecordVideoOperator) in Recording(end: { throw VideoStuck() }) })
            ])
        }
        
        // MARK: - Initializer
        // MARK: - Public
        // MARK: - Private
    }
    
    private final class UnstartableBackend: DeviceBackend {
        // MARK: - Property
        let info = DeviceInfo(udid: "udid-video", name: "stub", osVersion: "iOS 26.0", state: .booted)
        let failure: any Error
        
        var dispatchTable: DispatchTable {
            DispatchTable([.perform({ [failure] (_: RecordVideoOperator) -> Recording in throw failure })])
        }
        
        // MARK: - Initializer
        init(failure: any Error) {
            self.failure = failure
        }
        
        // MARK: - Public
        // MARK: - Private
    }
    
    // MARK: - Property
    private let directory: URL
    private let lock: DeviceLock
    private let sut: VideoLease
    
    // MARK: - Initializer
    init() {
        directory = URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true)
            .appendingPathComponent("digit-lease-test-\(UUID().uuidString)", isDirectory: true)
        lock = DeviceLock(directory: directory)
        sut = VideoLease(lock: lock)
    }
    
    // MARK: - Test
    @Test("a video closed cleanly leaves the channel free")
    func aCleanlyClosedVideoLeavesTheChannelFree() async throws {
        try await cleaned {
            // When
            try await sut.recording(on: "udid-a", to: "/tmp/one.mp4") { try $0.closed() }
            try await sut.recording(on: "udid-a", to: "/tmp/two.mp4") { try $0.closed() }
            
            // Then
            let marker = try sut.marker(for: "udid-a")
            
            #expect(!FileManager.default.fileExists(atPath: marker.path))
        }
    }
    
    @Test("a video never said to be closed refuses the next one")
    func aVideoNeverSaidToBeClosedRefusesTheNextOne() async throws {
        try await cleaned {
            // Given
            try await sut.recording(on: "udid-a", to: "/tmp/one.mp4") { _ in }
            
            // When / Then
            await #expect(throws: DigitError.self) {
                try await sut.recording(on: "udid-a", to: "/tmp/two.mp4") { _ in
                    Issue.record("a device still recording must not be handed a second video")
                }
            }
        }
    }
    
    @Test("the refusal names the unclosed video and the marker to remove")
    func theRefusalCarriesItsOwnRecovery() async throws {
        try await cleaned {
            // Given
            try await sut.recording(on: "udid-a", to: "/tmp/one.mp4") { _ in }
            
            // When
            let refusal = await #expect(throws: DigitError.self) {
                try await sut.recording(on: "udid-a", to: "/tmp/two.mp4") { _ in }
            }
            
            // Then
            let error = try #require(refusal)
            
            guard case .videoUnclosed = error else {
                Issue.record("\(error) is not the unclosed video")
                
                return
            }
            
            #expect("\(error)".contains("/tmp/one.mp4"))
            let marker = try sut.marker(for: "udid-a")
            
            #expect("\(error)".contains(marker.path))
        }
    }
    
    @Test("the lease is per device")
    func theLeaseIsPerDevice() async throws {
        try await cleaned {
            // Given
            try await sut.recording(on: "udid-a", to: "/tmp/one.mp4") { _ in }
            
            // When / Then
            try await sut.recording(on: "udid-b", to: "/tmp/two.mp4") { try $0.closed() }
        }
    }
    
    @Test("a stop that failed loses the video and leaves the channel taken")
    func aStopThatFailedLeavesTheChannelTaken() async throws {
        try await cleaned {
            // Given
            let device = Device(backend: UnstoppableBackend(), lock: lock)
            
            // When
            let recorded = try await device.recordVideo(to: "/tmp/one.mp4") {}
            
            guard case .recordingFailed = recorded.lost else {
                Issue.record("a video that would not close is lost to the recorder's failure")
                
                return
            }
            
            // Then
            let refusal = await #expect(throws: UnstartedRecording.self) {
                _ = try await device.recordVideo(to: "/tmp/two.mp4") {
                    Issue.record("the video is still open, so the second must not start")
                }
            }
            let error = try #require(refusal)
            
            guard case .videoUnclosed = error.reason else {
                Issue.record("\(error) is not lost to the unclosed video")
                
                return
            }
        }
    }
    
    @Test("a work that failed under a video that would not close comes back as it was, beside the lost video")
    func aFailedWorkUnderAStuckVideoComesBesideIt() async throws {
        try await cleaned {
            // Given
            let device = Device(backend: UnstoppableBackend(), lock: lock)
            
            // When
            let recorded = try await device.recordVideo(to: "/tmp/one.mp4") { throw WorkFailed() }
            
            // Then
            guard case let .failure(failure) = recorded.outcome, case .recordingFailed = recorded.lost else {
                Issue.record("\(recorded) does not hold the work's failure beside the lost video")
                
                return
            }
            
            #expect(failure is WorkFailed)
        }
    }
    
    @Test("a work that failed under a video that closed comes back as its failure, and the video is kept")
    func aFailedWorkUnderAClosedVideoComesBack() async throws {
        try await cleaned {
            // Given
            let device = Device(backend: VideoBackend(), lock: lock)
            
            // When
            let recorded = try await device.recordVideo(to: "/tmp/one.mp4") { throw WorkFailed() }
            
            // Then
            guard case let .failure(failure) = recorded.outcome else {
                Issue.record("\(recorded.outcome) is not the work's failure")
                
                return
            }
            
            #expect(failure is WorkFailed)
            #expect(recorded.lost == nil)
            _ = try await device.recordVideo(to: "/tmp/two.mp4") {}
        }
    }
    
    @Test("a recorder that cannot start loses the video before the work runs")
    func aRecorderThatCannotStartLosesTheVideo() async throws {
        try await cleaned {
            // Given
            let device = Device(backend: UnstartableBackend(failure: VideoStuck()), lock: lock)
            
            // When
            let lost = await #expect(throws: UnstartedRecording.self) {
                _ = try await device.recordVideo(to: "/tmp/one.mp4") {
                    Issue.record("a video that never started runs no work")
                }
            }
            
            // Then
            guard case .recordingFailed = try #require(lost).reason else {
                Issue.record("a recorder that cannot start is the recorder's failure")
                
                return
            }
        }
    }
    
    @Test("a run stopped while the video starts is interrupted")
    func aRunStoppedWhileStartingIsInterrupted() async throws {
        try await cleaned {
            // Given
            let device = Device(backend: UnstartableBackend(failure: CancellationError()), lock: lock)
            
            // When
            let stopped = await #expect(throws: DigitError.self) {
                _ = try await device.recordVideo(to: "/tmp/one.mp4") {}
            }
            
            // Then
            guard case .interrupted = try #require(stopped) else {
                Issue.record("a stop is an interruption, not a lost video")
                
                return
            }
        }
    }
    
    @Test("a video that closed hands the channel back")
    func aVideoThatClosedHandsTheChannelBack() async throws {
        try await cleaned {
            // Given
            let device = Device(backend: VideoBackend(), lock: lock)
            
            // When / Then
            _ = try await device.recordVideo(to: "/tmp/one.mp4") {}
            _ = try await device.recordVideo(to: "/tmp/two.mp4") {}
        }
    }
    
    @Test("a video hands back what the work under it returned")
    func aVideoHandsBackTheWork() async throws {
        try await cleaned {
            // Given
            let device = Device(backend: VideoBackend(), lock: lock)
            
            // When
            let recorded = try await device.recordVideo(to: "/tmp/one.mp4") { "done" }
            
            // Then
            #expect(try recorded.outcome.get() == "done")
            #expect(recorded.lost == nil)
        }
    }
    
    @Test("a log takes no lease, so it streams inside a video and beside another log")
    func aLogStreamsBesideAVideo() async throws {
        try await cleaned {
            // Given
            let device = Device(backend: LoggableBackend(), lock: lock)
            
            // When
            let recorded = try await device.recordVideo(to: "/tmp/one.mp4") {
                try await device.recordLog(to: "/tmp/one.log", matching: nil) {
                    try await device.recordLog(to: "/tmp/two.log", matching: nil) { "done" }
                }
            }
            
            // Then
            let outer = try recorded.outcome.get()
            let inner = try outer.outcome.get()
            
            #expect(recorded.lost == nil)
            #expect(outer.lost == nil)
            #expect(try inner.outcome.get() == "done")
        }
    }
    
    @Test("a device that cannot record leaves no marker")
    func aDeviceThatCannotRecordIsNotMarked() async throws {
        try await cleaned {
            // Given
            let device = Device(backend: DeafBackend(), lock: lock)
            
            // When
            for _ in 1...2 {
                await #expect(throws: CapabilityError.self) {
                    _ = try await device.recordVideo(to: "/tmp/one.mp4") {}
                }
            }
            
            // Then
            let marker = try sut.marker(for: "udid-deaf")
            
            #expect(!FileManager.default.fileExists(atPath: marker.path))
        }
    }
    
    @Test("a failure after the close does not hold the channel")
    func aFailureAfterTheCloseIsNotTheChannelsFault() async throws {
        struct Later: Error {}
        
        try await cleaned {
            // When
            await #expect(throws: Later.self) {
                try await sut.recording(on: "udid-a", to: "/tmp/one.mp4") {
                    try $0.closed()
                    
                    throw Later()
                }
            }
            
            // Then
            try await sut.recording(on: "udid-a", to: "/tmp/two.mp4") { try $0.closed() }
        }
    }
    
    // MARK: - Private
    private func cleaned(_ body: () async throws -> Void) async rethrows {
        defer { try? FileManager.default.removeItem(at: directory) }
        
        try await body()
    }
}

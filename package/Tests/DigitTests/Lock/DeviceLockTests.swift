//
//  DeviceLockTests.swift
//  DigitTests
//
//  Created by JSilver on 8/16/26.
//

import Foundation
import Testing
@testable import Digit

@Suite("A device lock holds one device for one holder")
struct DeviceLockTests {
    // MARK: - Property
    private let directory: URL
    private let sut: DeviceLock
    
    // MARK: - Initializer
    init() {
        directory = URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true)
            .appendingPathComponent("digit-lock-test-\(UUID().uuidString)", isDirectory: true)
        sut = DeviceLock(directory: directory)
    }
    
    // MARK: - Lifecycle
    // swift-testing has no teardown; each test removes its directory through `cleaned`.
    
    // MARK: - Test
    @Test("a released lock can be taken again")
    func aReleasedLockCanBeTakenAgain() throws {
        try cleaned {
            // When / Then
            try sut.withExclusiveAccess(to: "udid-a") {}
            try sut.withExclusiveAccess(to: "udid-a") {}
        }
    }
    
    @Test("a held device is refused to a second holder")
    func aHeldDeviceIsRefused() throws {
        try cleaned {
            // When / Then
            _ = try sut.withExclusiveAccess(to: "udid-a") {
                #expect(throws: DigitError.self) {
                    try sut.withExclusiveAccess(to: "udid-a") {
                        Issue.record("a held device must not be handed out twice")
                    }
                }
            }
        }
    }
    
    @Test("devices are locked independently")
    func devicesAreLockedIndependently() throws {
        try cleaned {
            // When / Then
            try sut.withExclusiveAccess(to: "udid-a") {
                try sut.withExclusiveAccess(to: "udid-b") {}
            }
        }
    }
    
    @Test("a span that throws still releases the lock")
    func aFailingSpanStillReleases() throws {
        struct Boom: Error {}
        
        try cleaned {
            // When
            #expect(throws: Boom.self) {
                try sut.withExclusiveAccess(to: "udid-a") { throw Boom() }
            }
            
            // Then
            try sut.withExclusiveAccess(to: "udid-a") {}
        }
    }
    
    @Test("the lock file stays after release")
    func theLockFileIsNotRemovedOnRelease() throws {
        try cleaned {
            // When
            try sut.withExclusiveAccess(to: "udid-a") {}
            
            // Then
            let path = try sut.path(for: "udid-a")
            
            #expect(path.deletingLastPathComponent().path == directory.path)
            #expect(FileManager.default.fileExists(atPath: path.path))
        }
    }
    
    @Test("the lock file is the udid with a .lock suffix")
    func theLockPathFollowsTheConvention() throws {
        // When
        let path = try sut.path(for: "udid-a")
        
        // Then
        #expect(path == directory.appendingPathComponent("udid-a.lock"))
    }
    
    @Test("the device and its video have separate lock files")
    func eachHeldThingHasItsOwnFile() throws {
        // When
        let device = try sut.path(for: "udid-a", holding: .device)
        let video = try sut.path(for: "udid-a", holding: .video)
        
        // Then
        #expect(device != video)
        #expect(video.lastPathComponent == "udid-a.video.lock")
    }
    
    @Test("holding the video leaves the device free")
    func holdingTheVideoLeavesTheDeviceFree() throws {
        try cleaned {
            // When / Then
            try sut.withExclusiveAccess(to: "udid-a", holding: .video) {
                try sut.withExclusiveAccess(to: "udid-a", holding: .device) {}
            }
        }
    }
    
    @Test("a device already recording is refused a second recording")
    func aDeviceAlreadyRecordingIsRefused() throws {
        try cleaned {
            // When / Then
            _ = try sut.withExclusiveAccess(to: "udid-a", holding: .video) {
                #expect(throws: DigitError.self) {
                    try sut.withExclusiveAccess(to: "udid-a", holding: .video) {
                        Issue.record("one device cannot be recorded twice at once")
                    }
                }
            }
        }
    }
    
    @Test("a udid that would leave the lock directory is refused", arguments: ["", "../elsewhere", "a/b", ".", ".."])
    func aUdidThatIsNotOneIsRefused(udid: String) {
        // When / Then
        #expect(throws: DigitError.self) { _ = try sut.path(for: udid) }
    }
    
    // MARK: - Private
    private func cleaned(_ body: () throws -> Void) rethrows {
        defer { try? FileManager.default.removeItem(at: directory) }
        
        try body()
    }
}

//
//  DeviceTests.swift
//  DigitTests
//
//  Created by JSilver on 8/16/26.
//

import Foundation
import Testing
@testable import Digit

@Suite("A device runs an operation only through its backend's dispatch table")
struct DeviceTests {
    private final class BootBackend: DeviceBackend {
        // MARK: - Property
        let info = DeviceInfo(udid: "STUB", name: "stub", osVersion: "iOS 26.0", state: .shutdown)
        
        var dispatchTable: DispatchTable {
            DispatchTable(bootable ? [.perform(boot)] : [])
        }
        
        private(set) var bootCalls = 0
        
        private let bootable: Bool
        
        // MARK: - Initializer
        init(bootable: Bool) {
            self.bootable = bootable
        }
        
        // MARK: - Public
        // MARK: - Private
        private func boot(_: BootOperator) { bootCalls += 1 }
    }
    
    private final class FailingBackend: DeviceBackend {
        // MARK: - Property
        let info = DeviceInfo(udid: "STUB", name: "stub", osVersion: "iOS 26.0", state: .booted)
        
        var dispatchTable: DispatchTable {
            DispatchTable([.perform(boot)])
        }
        
        private let error: any Error
        
        // MARK: - Initializer
        init(throwing error: any Error) {
            self.error = error
        }
        
        // MARK: - Public
        // MARK: - Private
        private func boot(_: BootOperator) throws { throw error }
    }
    
    private final class NotingBackend: DeviceBackend {
        // MARK: - Property
        let info = DeviceInfo(udid: "STUB", name: "stub", osVersion: "iOS 26.0", state: .booted)
        
        private(set) var reached: Set<Digit.Operation> = []
        
        var dispatchTable: DispatchTable {
            DispatchTable([
                .perform(note as (BootOperator) -> Void),
                .perform(note as (ShutdownOperator) -> Void),
                .perform(note as (RebootOperator) -> Void),
                .perform(note as (EraseOperator) -> Void),
                .perform(note as (InstallAppOperator) -> Void),
                .perform(note as (UninstallAppOperator) -> Void),
                .perform({ (operation: LaunchAppOperator) in self.note(operation); return 1 }),
                .perform(note as (TerminateAppOperator) -> Void),
                .perform({ (operation: AppStateOperator) in self.note(operation); return .foreground }),
                .perform({ (operation: ListAppsOperator) in self.note(operation); return [] }),
                .perform({ (operation: AppContainerOperator) in self.note(operation); return "/tmp/app" }),
                .perform({ (operation: AppGroupsOperator) in self.note(operation); return [:] }),
                .perform({ (operation: DescribeUIOperator) in self.note(operation); return [] }),
                .perform({ (operation: DescribeScreenOperator) in
                    self.note(operation)
                    
                    return try Screen(width: 100, height: 200)
                }),
                .perform({ (operation: ScreenshotOperator) in self.note(operation); return Data() }),
                .perform({ (operation: RecordVideoOperator) in self.note(operation); return Recording {} }),
                .perform({ (operation: RecordLogOperator) in self.note(operation); return Recording {} }),
                .perform({ (operation: StreamVideoOperator) in self.note(operation); return VideoStream {} }),
                .perform(note as (TapOperator) -> Void),
                .perform(note as (LongPressOperator) -> Void),
                .perform(note as (SwipeOperator) -> Void),
                .perform(note as (DragOperator) -> Void),
                .perform(note as (TypeTextOperator) -> Void),
                .perform(note as (PressKeyOperator) -> Void),
                .perform(note as (PressButtonOperator) -> Void),
                .perform(note as (MoveSliderOperator) -> Void),
                .perform(note as (RespondBiometricOperator) -> Void),
                .perform(note as (SetAppearanceOperator) -> Void),
                .perform(note as (SetContentSizeOperator) -> Void),
                .perform(note as (SetContrastOperator) -> Void),
                .perform(note as (SetPrivacyOperator) -> Void),
                .perform(note as (SetLocationOperator) -> Void),
                .perform(note as (SetStatusBarOperator) -> Void),
                .perform(note as (SetOrientationOperator) -> Void),
                .perform(note as (SetHingeOperator) -> Void),
                .perform(note as (SetHardwareKeyboardOperator) -> Void),
                .perform(note as (SetAppAccessibilityOperator) -> Void),
                .perform({ (operation: AppAccessibilityOperator) in self.note(operation); return .enabled }),
                .perform(note as (AddMediaOperator) -> Void),
                .perform(note as (AddCertificateOperator) -> Void),
                .perform(note as (ResetKeychainOperator) -> Void),
                .perform(note as (OpenURLOperator) -> Void),
                .perform(note as (PushNotificationOperator) -> Void),
                .perform(note as (SetPasteboardOperator) -> Void),
                .perform({ (operation: ReadPasteboardOperator) in self.note(operation); return "" })
            ])
        }
        
        // MARK: - Initializer
        // MARK: - Public
        // MARK: - Private
        private func note<O: Operator>(_: O) { reached.insert(O.operation) }
    }
    
    // MARK: - Property
    // MARK: - Initializer
    // MARK: - Test
    @Test("an operation the backend lacks is refused before reaching it")
    func unsupportedOperationFailsLoud() async {
        // Given
        let backend = BootBackend(bootable: false)
        let sut = Device(backend: backend)
        
        // When / Then
        await #expect(throws: CapabilityError.self) {
            try await sut.run(BootOperator())
        }
        #expect(backend.bootCalls == 0)
    }
    
    @Test("an operation with a result is refused the same way")
    func unsupportedOperationWithResultFailsLoud() async {
        // Given
        let sut = Device(backend: BootBackend(bootable: false))
        
        // When / Then
        await #expect(throws: CapabilityError.self) {
            _ = try await sut.run(DescribeUIOperator())
        }
    }
    
    @Test("what a backend's framework throws leaves the device as a failed command")
    func aFrameworkErrorIsACommandFailure() async {
        // Given
        let thrown = NSError(domain: "com.facebook.FBControlCore", code: 3, userInfo: [
            NSLocalizedDescriptionKey: "no such process"
        ])
        let sut = Device(backend: FailingBackend(throwing: thrown))
        
        // When
        let error = await #expect(throws: DigitError.self) {
            try await sut.run(BootOperator())
        }
        
        // Then
        guard case let .commandFailed(command, message)? = error else {
            Issue.record("\(String(describing: error)) is not a failed command")
            
            return
        }
        
        #expect(command == "boot")
        #expect(message == "no such process")
    }
    
    @Test("an operation a backend finds it cannot do leaves the device as a capability error")
    func aCapabilityErrorPassesThrough() async {
        // Given
        let info = DeviceInfo(udid: "STUB", name: "stub", osVersion: "iOS 26.0", state: .booted)
        let sut = Device(backend: FailingBackend(throwing: CapabilityError(operation: .setHinge, target: info)))
        
        // When / Then
        await #expect(throws: CapabilityError.self) {
            try await sut.run(BootOperator())
        }
    }
    
    @Test("a cancellation inside a backend leaves the device as an interruption")
    func aCancellationIsAnInterruption() async {
        // Given
        let sut = Device(backend: FailingBackend(throwing: CancellationError()))
        
        // When
        let error = await #expect(throws: DigitError.self) {
            try await sut.run(BootOperator())
        }
        
        // Then
        guard case .interrupted? = error else {
            Issue.record("\(String(describing: error)) is not an interruption")
            
            return
        }
    }
    
    @Test("a DigitError a backend throws leaves the device as it is")
    func aDigitErrorPassesThrough() async {
        // Given
        let sut = Device(backend: FailingBackend(throwing: DigitError.deviceBusy(udid: "STUB")))
        
        // When
        let error = await #expect(throws: DigitError.self) {
            try await sut.run(BootOperator())
        }
        
        // Then
        guard case .deviceBusy("STUB")? = error else {
            Issue.record("\(String(describing: error)) is not the error thrown")
            
            return
        }
    }
    
    @Test("an operation the backend has reaches its implementation once")
    func supportedOperationReachesBackend() async throws {
        // Given
        let backend = BootBackend(bootable: true)
        let sut = Device(backend: backend)
        
        // When
        try await sut.run(BootOperator())
        
        // Then
        #expect(backend.bootCalls == 1)
    }
    
    @Test("capabilities are the operations the dispatch table holds")
    func capabilityIsDerivedFromImplementations() {
        // Given
        let sut = Device(backend: BootBackend(bootable: true))
        
        // When / Then
        #expect(sut.capabilities == [.boot])
    }
    
    @Test("every operation reaches the implementation written for it")
    func everyOperationReachesItsImplementation() async throws {
        // Given
        let directory = URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true)
            .appendingPathComponent("digit-device-test-\(UUID().uuidString)", isDirectory: true)
        defer { try? FileManager.default.removeItem(at: directory) }
        
        let backend = NotingBackend()
        let sut = Device(backend: backend, lock: DeviceLock(directory: directory))
        let line = try Stroke(start: Point(x: 0, y: 0), end: Point(x: 1, y: 1), duration: 0.3)
        
        // When
        try await sut.run(BootOperator())
        try await sut.run(ShutdownOperator())
        try await sut.run(RebootOperator())
        try await sut.run(EraseOperator())
        try await sut.run(InstallAppOperator(path: "/tmp/app"))
        try await sut.run(UninstallAppOperator(bundleID: "com.example"))
        _ = try await sut.run(LaunchAppOperator(bundleID: "com.example"))
        try await sut.run(TerminateAppOperator(bundleID: "com.example"))
        _ = try await sut.run(AppStateOperator(bundleID: "com.example"))
        _ = try await sut.run(ListAppsOperator())
        _ = try await sut.run(AppContainerOperator(bundleID: "com.example"))
        _ = try await sut.run(AppGroupsOperator(bundleID: "com.example"))
        _ = try await sut.run(DescribeUIOperator())
        _ = try await sut.run(DescribeScreenOperator())
        _ = try await sut.run(ScreenshotOperator())
        _ = try await sut.recordVideo(to: "/tmp/out.mp4") {}
        _ = try await sut.recordLog(to: "/tmp/out.log", matching: nil) {}
        _ = try await sut.run(try StreamVideoOperator { _ in })
        try await sut.run(TapOperator(at: Point(x: 1, y: 2)))
        try await sut.run(try LongPressOperator(at: Point(x: 1, y: 2), duration: 0.5))
        try await sut.run(SwipeOperator(line))
        try await sut.run(DragOperator(line))
        try await sut.run(try TypeTextOperator("a"))
        try await sut.run(PressKeyOperator(press: try #require(KeyPress(code: 4))))
        try await sut.run(PressButtonOperator(.home))
        try await sut.run(
            try MoveSliderOperator(
                frame: Element.Frame(x: 0, y: 0, width: 100, height: 40),
                from: 0,
                to: 0.5,
                duration: 0.4
            )
        )
        try await sut.run(RespondBiometricOperator(.match))
        try await sut.run(SetAppearanceOperator(.dark))
        try await sut.run(SetContentSizeOperator(.large))
        try await sut.run(SetContrastOperator(.increased))
        try await sut.run(
            try SetPrivacyOperator(decision: .grant, bundleID: "com.example", services: [.camera])
        )
        try await sut.run(SetLocationOperator(.fixed(try Coordinate(latitude: 0, longitude: 0))))
        try await sut.run(try SetStatusBarOperator(time: "9:41"))
        try await sut.run(SetOrientationOperator(.landscapeLeft))
        try await sut.run(SetHingeOperator(.unfolded))
        try await sut.run(SetHardwareKeyboardOperator(.disconnected))
        try await sut.run(SetAppAccessibilityOperator(.enabled))
        _ = try await sut.run(AppAccessibilityOperator())
        try await sut.run(try AddMediaOperator(paths: ["/tmp/a.png"]))
        try await sut.run(AddCertificateOperator(path: "/tmp/proxy.pem", root: true))
        try await sut.run(ResetKeychainOperator())
        try await sut.run(OpenURLOperator(try #require(URL(string: "https://example.com"))))
        try await sut.run(
            try PushNotificationOperator(bundleID: "com.example", payload: #"{"aps":{"alert":"hi"}}"#)
        )
        try await sut.run(SetPasteboardOperator("hi"))
        _ = try await sut.run(ReadPasteboardOperator())
        
        // Then
        #expect(backend.reached == Set(Digit.Operation.allCases))
    }
    
    // MARK: - Private
}

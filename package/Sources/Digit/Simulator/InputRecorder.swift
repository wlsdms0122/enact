//
//  InputRecorder.swift
//  Digit
//
//  Created by JSilver on 11/13/26.
//

import FBControlCore
import FBSimulatorControl
import Foundation

// Records the input a simulator is given through the test daemon inside it, the way
// Xcode's UI test recorder does: a recording session of Xcode's XCTDaemonControl,
// loaded from the Xcode Digit runs with when a recording starts. None of it is a
// contract, so an Xcode that renames a class or a selector is answered here.
enum InputRecorder {
    // MARK: - Property
    private static let frameworks = ["DTXConnectionServices", "XCTestCore", "XCTAutomationSupport", "XCTDaemonControl"]
    // The variable the device's launchd holds the daemon's socket path in.
    private static let socketVariable = "TESTMANAGERD_SIM_SOCK"
    // What a snapshot reads of each element. An attribute whose value is a list, as
    // the children, is refused by the snapshot's decoder and takes the event with it;
    // children come in the snapshot's own structure.
    private static let attributes = [
        "ElementType", "ElementBaseType", "Parent", "Identifier", "AutomationType", "Traits",
        "Label", "Value", "Frame", "PlaceholderValue"
    ].map { name in "XC_kAXXCAttribute\(name)" }
    
    private static let loading = Result { try load() }
    
    // MARK: - Public
    // Records the application of the process and, as the daemon follows the screen,
    // whichever comes to the front after it.
    static func start(
        on simulator: Simulator,
        process: Int32,
        sink: @escaping @Sendable (InputEvent) -> Void
    ) async throws -> InputRecording {
        try loading.get()
        
        let queue = DispatchQueue(label: "digit.input-recording")
        let provider = try connectionProvider(for: simulator)
        let session = try await recordingSession(through: provider)
        let delegate = InputRecordingDelegate(sink: sink)
        let configuration = try configuration()
        
        // The session takes the daemon's calls only once it is the channel's exported
        // object, which the session leaves to whoever holds it.
        _ = session.daemonProxy.perform(NSSelectorFromString("setExportedObject:queue:"), with: session, with: queue)
        session.setDelegate(delegate, callbackQueue: queue, logDelegate: nil)
        
        let started = await withCheckedContinuation { continuation in
            session.startRecording(process: process, configuration: configuration) { started in
                continuation.resume(returning: started)
            }
        }
        
        guard started else {
            session.invalidate()
            
            throw DigitError.recordingFailed(reason: "the test daemon did not start recording process \(process)")
        }
        
        nonisolated(unsafe) let held = (provider, session, delegate)
        
        return InputRecording {
            held.1.stopRecording()
            held.1.invalidate()
            _ = held.0.perform(NSSelectorFromString("invalidate"))
            _ = held.2
        }
    }
    
    // MARK: - Private
    private static func load() throws {
        let shared = URL(fileURLWithPath: XcodeConfiguration.developerDirectory)
            .deletingLastPathComponent()
            .appending(path: "SharedFrameworks")
        
        for name in frameworks {
            let path = shared.appending(path: "\(name).framework/\(name)").path
            
            guard dlopen(path, RTLD_NOW | RTLD_GLOBAL) != nil else {
                throw DigitError.recordingFailed(reason: "loading \(path): \(String(cString: dlerror()))")
            }
        }
    }
    
    private static func connectionProvider(for simulator: Simulator) throws -> NSObject {
        let allocated = try type(named: "XCTSimulatorDeviceDTXConnectionProvider").perform(NSSelectorFromString("alloc"))
        
        // `alloc` hands over the instance and the initializer takes it, returning the
        // one it made, which is the caller's to own.
        guard let made = allocated?.takeUnretainedValue()
            .perform(NSSelectorFromString("initWithSimDevice:serviceName:"), with: simulator.device, with: socketVariable)?
            .takeRetainedValue() as? NSObject
        else {
            throw DigitError.recordingFailed(reason: "the test daemon's connection could not be made")
        }
        
        return made
    }
    
    private static func recordingSession(through provider: NSObject) async throws -> RecordingSession {
        let requesting = try type(named: "XCTDaemonRecordingSession")
        
        let session: Unchecked<RecordingSession> = try await withCheckedThrowingContinuation { continuation in
            let completion: @convention(block) (AnyObject?, NSError?) -> Void = { session, error in
                guard let session else {
                    let reason = error.map { error in error.localizedDescription } ?? "no session came back"
                    
                    continuation.resume(throwing: DigitError.recordingFailed(reason: "the test daemon: \(reason)"))
                    
                    return
                }
                
                continuation.resume(returning: Unchecked(value: unsafeBitCast(session, to: RecordingSession.self)))
            }
            
            _ = requesting.perform(
                NSSelectorFromString("requestSessionWithDTXConnectionProvider:completion:"),
                with: provider,
                with: unsafeBitCast(completion, to: AnyObject.self)
            )
        }
        
        return session.value
    }
    
    private static func configuration() throws -> NSObject {
        let configuration = try type(named: "XCTDaemonRecordingConfiguration").init()
        
        configuration.setValue(attributes, forKey: "applicationSnapshotAttributes")
        configuration.setValue([String: Any](), forKey: "applicationSnapshotParameters")
        configuration.setValue(attributes, forKey: "elementSnapshotAttributes")
        configuration.setValue([String: Any](), forKey: "elementSnapshotParameters")
        
        return configuration
    }
    
    private static func type(named name: String) throws -> NSObject.Type {
        guard let found = NSClassFromString(name) as? NSObject.Type else {
            throw DigitError.recordingFailed(reason: "this Xcode has no \(name)")
        }
        
        return found
    }
}

// An Objective-C object handed between the daemon's queue and the caller, which only
// the caller uses from then on.
private struct Unchecked<Value>: @unchecked Sendable {
    let value: Value
}

// The recording session's own methods, called through the Objective-C runtime.
@objc private protocol RecordingSession {
    var daemonProxy: NSObject { get }
    
    @objc(setDelegate:callbackQueue:logDelegate:)
    func setDelegate(_ delegate: AnyObject?, callbackQueue: DispatchQueue, logDelegate: AnyObject?)
    
    @objc(startRecordingProcessID:configuration:completion:)
    func startRecording(process: Int32, configuration: AnyObject?, completion: @escaping (Bool) -> Void)
    
    func stopRecording()
    func invalidate()
}

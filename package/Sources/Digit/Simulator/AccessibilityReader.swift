//
//  AccessibilityReader.swift
//  Digit
//
//  Created by JSilver on 11/2/26.
//

import FBSimulatorAX
import FBSimulatorControl
import Foundation

// Reads a simulator's accessibility tree, first waking the frontmost application, which
// starts its accessibility server only while application accessibility is on. A read
// turns it on where it is off and leaves it on, so the servers of processes started
// later, as a web view's content, run too. Where it is already on, an application that
// answers as its bare element has not drawn yet, and the read returns it as it is.
struct AccessibilityReader {
    // MARK: - Property
    // A single read on a freshly booted device can take several seconds.
    private static let wakeTimeout: Duration = .seconds(10)
    private static let wakePollInterval: Duration = .milliseconds(200)
    
    private let simulator: Simulator
    private let applePrivate: ApplePrivate
    
    // MARK: - Initializer
    init(simulator: Simulator) {
        self.simulator = simulator
        self.applePrivate = ApplePrivate(simulator: simulator)
    }
    
    // MARK: - Public
    // Remote content is what another process draws inside the read application, which
    // its tree leaves out and only a press at a point reaches.
    func read(
        _ query: AccessibilityElementQuery,
        remoteContent: AccessibilityRemoteContentOptions? = nil
    ) async throws -> [AccessibilityDocumentElement] {
        try SimulatorFrameworkBridge.install()
        
        if try !applePrivate.isApplicationAccessibilityEnabled() {
            try await wakeFrontmost()
        }
        
        do {
            return try await describe(query, remoteContent: remoteContent)
        } catch let AccessibilityError.noTranslationObject(failed) where failed == .frontmost {
            throw DigitError.unreadableOutput(
                of: "accessibility tree",
                reason: "the device names no frontmost application. One read too soon after it "
                    + "booted can stay so until it boots again"
            )
        }
    }
    
    // A read at a point is safe at any time, where a frontmost read before SpringBoard's
    // accessibility is ready can leave the device unable to name its frontmost
    // application until it boots again. The center answers once whatever is drawn
    // there does. A device with more than one screen names its integrated one some
    // seconds after it boots.
    func answersAtScreenCenter() async throws -> Bool {
        try SimulatorFrameworkBridge.install()
        
        do {
            let size = try await simulator.displays.configuration().activeGeometry().pointSize
            
            return try await !describe(.point(CGPoint(x: size.width / 2, y: size.height / 2))).isEmpty
        } catch is AccessibilityError {
            return false
        } catch is SimulatorDisplayError {
            return false
        } catch SimulatorDisplayInteractionError.unsupportedCapability {
            return false
        }
    }
    
    // MARK: - Private
    // The accessibility service can fall silent for a moment, so a read it
    // does not answer is asked once more.
    private func describe(
        _ query: AccessibilityElementQuery,
        remoteContent: AccessibilityRemoteContentOptions? = nil
    ) async throws -> [AccessibilityDocumentElement] {
        do {
            return try await tree(of: query, remoteContent: remoteContent)
        } catch AccessibilityError.serviceNotAnswering {
            return try await tree(of: query, remoteContent: remoteContent)
        }
    }
    
    private func tree(
        of query: AccessibilityElementQuery,
        remoteContent: AccessibilityRemoteContentOptions?
    ) async throws -> [AccessibilityDocumentElement] {
        // The process each element belongs to tells SpringBoard's frames apart.
        try await simulator.uiAutomation(backend: .accessibility)
            .describe(
                query,
                options: AccessibilityRequestOptions(
                    format: .nested,
                    keys: AXKeys.defaultSet.union([.pid, .isRemote]),
                    remoteContentOptions: remoteContent
                )
            )
            .elements.elements
    }
    
    // Turning the setting on again notifies an application that slept through it.
    private func wakeFrontmost() async throws {
        try await applePrivate.setApplicationAccessibility(enabled: true)
        
        guard try await pollUntilAwake() else {
            throw DigitError.unreadableOutput(
                of: "accessibility tree",
                reason: "the frontmost app's accessibility server did not start within "
                    + "\(Self.wakeTimeout)"
            )
        }
    }
    
    private func pollUntilAwake() async throws -> Bool {
        let deadline = ContinuousClock.now + Self.wakeTimeout
        
        while try await isFrontmostAsleep() {
            guard ContinuousClock.now < deadline else { return false }
            
            try await Task.sleep(for: Self.wakePollInterval)
        }
        
        return true
    }
    
    // A sleeping application answers a frontmost read as its bare element, or before it
    // has ever answered, not at all.
    private func isFrontmostAsleep() async throws -> Bool {
        do {
            let elements = try await describe(.frontmost)
            
            return elements.count == 1 && elements[0].isSilentApplication
        } catch AccessibilityError.noTranslationObject {
            return true
        }
    }
}

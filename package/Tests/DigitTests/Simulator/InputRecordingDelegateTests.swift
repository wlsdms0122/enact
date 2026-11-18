//
//  InputRecordingDelegateTests.swift
//  DigitTests
//
//  Created by JSilver on 11/13/26.
//

import Foundation
import Synchronization
import Testing
@testable import Digit

@Suite("What the recording session tells is input in the words Digit's input operations take")
struct InputRecordingDelegateTests {
    // The properties of the session's key events the reading takes.
    private final class Keys: NSObject {
        // MARK: - Property
        @objc let characters: String
        @objc let charactersIgnoringModfiers: String
        @objc let modifierFlags: NSNumber
        
        // MARK: - Initializer
        init(_ characters: String, _ unmodified: String, flags: UInt64) {
            self.characters = characters
            self.charactersIgnoringModfiers = unmodified
            self.modifierFlags = NSNumber(value: flags)
        }
    }
    
    // The properties of the session's events the reading takes.
    private final class Event: NSObject {
        // MARK: - Property
        @objc let eventNames: [String]
        @objc let timestamp = NSNumber(value: 0)
        @objc let duration = NSNumber(value: 0.1)
        @objc let startLocation: [String: Any]? = ["x": 1, "y": 2]
        @objc let startElementSnapshot: NSObject? = nil
        @objc let startApplicationSnapshot: NSObject? = nil
        
        // MARK: - Initializer
        init(_ names: [String]) {
            self.eventNames = names
        }
    }
    
    // MARK: - Property
    // MARK: - Initializer
    // MARK: - Test
    @Test(
        "a key is named as press-key names it, with the modifiers held but a shift its character holds",
        arguments: [
            ("a", "a", 0, InputEvent.Key(key: "a", modifiers: [])),
            ("A", "A", 1 << 17, InputEvent.Key(key: "A", modifiers: [])),
            ("\r", "\r", 0, InputEvent.Key(key: "return", modifiers: [])),
            ("\u{F729}", "\u{F729}", 0, InputEvent.Key(key: "home", modifiers: [])),
            ("\u{F702}", "\u{F702}", 1 << 17, InputEvent.Key(key: "left", modifiers: [.shift])),
            ("\u{19}", "\u{19}", 1 << 17, InputEvent.Key(key: "tab", modifiers: [.shift])),
            ("ç", "c", 1 << 19 | 1 << 20, InputEvent.Key(key: "c", modifiers: [.option, .command]))
        ] as [(String, String, UInt64, InputEvent.Key)]
    )
    func keysAreNamed(characters: String, unmodified: String, flags: UInt64, key: InputEvent.Key) {
        // Given
        let received = Mutex<[InputEvent]>([])
        let sut = InputRecordingDelegate(sink: { event in received.withLock { events in events.append(event) } }, disconnected: {})
        
        // When
        sut.recordingSession(NSObject(), didRecordKeyEvents: Keys(characters, unmodified, flags: flags))
        
        // Then
        let events = received.withLock { events in events }
        
        guard events.count == 1, case let .key(read) = events[0] else {
            Issue.record("\(events) is not one key")
            
            return
        }
        
        #expect(read == key)
    }
    
    @Test("once ended, nothing more is told")
    func endedTellsNothing() {
        // Given
        let received = Mutex<[InputEvent]>([])
        let sut = InputRecordingDelegate(sink: { event in received.withLock { events in events.append(event) } }, disconnected: {})
        
        sut.recordingSession(NSObject(), didRecordEvent: Event(["tap"]))
        
        // When
        sut.end()
        sut.recordingSession(NSObject(), didRecordEvent: Event(["tap"]))
        sut.recordingSession(NSObject(), didRecordApplicationActivated: "com.apple.Preferences")
        
        // Then
        #expect(received.withLock { events in events.count } == 1)
    }
    
    @Test("a session disconnected is told once, and nothing more after it")
    func disconnectedIsTold() {
        // Given
        let received = Mutex<[InputEvent]>([])
        let disconnections = Mutex(0)
        let sut = InputRecordingDelegate(
            sink: { event in received.withLock { events in events.append(event) } },
            disconnected: { disconnections.withLock { count in count += 1 } }
        )
        
        // When
        sut.recordingSessionDidDisconnect(NSObject())
        sut.recordingSessionDidDisconnect(NSObject())
        sut.recordingSession(NSObject(), didRecordEvent: Event(["tap"]))
        
        // Then
        #expect(disconnections.withLock { count in count } == 1)
        #expect(received.withLock { events in events.isEmpty })
    }
    
    @Test("once ended, a session disconnected is not told")
    func endedTellsNoDisconnection() {
        // Given
        let disconnections = Mutex(0)
        let sut = InputRecordingDelegate(sink: { _ in }, disconnected: { disconnections.withLock { count in count += 1 } })
        
        // When
        sut.end()
        sut.recordingSessionDidDisconnect(NSObject())
        
        // Then
        #expect(disconnections.withLock { count in count } == 0)
    }
    
    @Test("the home button's press is the button, its release nothing, and a gesture is told by its names")
    func buttonsAndGestures() {
        // Given
        let received = Mutex<[InputEvent]>([])
        let sut = InputRecordingDelegate(sink: { event in received.withLock { events in events.append(event) } }, disconnected: {})
        
        // When
        for names in [["XCUIEventTypeMenuButtonDown"], ["XCUIEventTypeACHomeUp"], ["tap"]] {
            sut.recordingSession(NSObject(), didRecordEvent: Event(names))
        }
        
        // Then
        let events = received.withLock { events in events }
        
        guard events.count == 2, case .button(.home) = events[0], case let .gesture(gesture) = events[1] else {
            Issue.record("\(events) are not the home button and a gesture")
            
            return
        }
        
        #expect(gesture.names == ["tap"])
        #expect(gesture.point == Point(x: 1, y: 2))
    }
}

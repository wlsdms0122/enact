//
//  InputRecordingDelegate.swift
//  Digit
//
//  Created by JSilver on 11/13/26.
//

import Foundation

// What a recording session tells, as input events: its delegate methods are called
// through the Objective-C runtime by name.
final class InputRecordingDelegate: NSObject, @unchecked Sendable {
    // MARK: - Property
    private static let buttonEvent = "XCUIEventType"
    private static let buttons: [String: Button] = ["MenuButtonDown": .home]
    // AppKit's modifier flags.
    private static let modifierFlags: [(Modifier, UInt64)] = [
        (.shift, 1 << 17), (.control, 1 << 18), (.option, 1 << 19), (.command, 1 << 20)
    ]
    // The characters AppKit makes for the keys press-key names.
    private static let keyNames: [Character: String] = [
        "\r": "return", "\n": "return", "\u{3}": "return", "\t": "tab", "\u{1B}": "escape",
        "\u{7F}": "delete", "\u{8}": "delete", " ": "space",
        "\u{F700}": "up", "\u{F701}": "down", "\u{F702}": "left", "\u{F703}": "right",
        "\u{F729}": "home", "\u{F72B}": "end", "\u{F72C}": "page-up", "\u{F72D}": "page-down"
    ]
    
    // Read and ended on the session's callback queue alone.
    private var sink: (@Sendable (InputEvent) -> Void)?
    
    // MARK: - Initializer
    init(sink: @escaping @Sendable (InputEvent) -> Void) {
        self.sink = sink
    }
    
    // MARK: - Public
    // Tells nothing from here on. Called on the session's callback queue, so an
    // event being told is told whole before it.
    func end() {
        sink = nil
    }
    
    @objc(recordingSession:didRecordEvent:)
    func recordingSession(_ session: AnyObject, didRecordEvent event: NSObject) {
        let names = event.value(forKey: "eventNames") as? [String] ?? []
        
        // The device tells a button's press and its release as events of their own.
        if let name = names.first, name.hasPrefix(Self.buttonEvent) {
            if let button = Self.buttons[String(name.dropFirst(Self.buttonEvent.count))] { sink?(.button(button)) }
            
            return
        }
        
        let location = event.value(forKey: "startLocation") as? [String: Any]
        let point = location.flatMap { location -> Point? in
            guard let x = (location["x"] as? NSNumber)?.doubleValue, let y = (location["y"] as? NSNumber)?.doubleValue else { return nil }
            
            return Point(x: x, y: y)
        }
        let gesture = InputEvent.Gesture(
            names: names,
            time: Date(timeIntervalSinceReferenceDate: (event.value(forKey: "timestamp") as? NSNumber)?.doubleValue ?? 0),
            duration: (event.value(forKey: "duration") as? NSNumber)?.doubleValue ?? 0,
            point: point,
            element: (event.value(forKey: "startElementSnapshot") as? NSObject).map(Element.init(snapshot:)),
            application: (event.value(forKey: "startApplicationSnapshot") as? NSObject).map(Element.init(snapshot:))
        )
        
        sink?(.gesture(gesture))
    }
    
    // Keys come as AppKit tells them: the characters made, the ones made without
    // the modifiers, and the modifier flags.
    @objc(recordingSession:didRecordKeyEvents:)
    func recordingSession(_ session: AnyObject, didRecordKeyEvents keys: NSObject) {
        let characters = keys.value(forKey: "characters") as? String ?? ""
        let unmodified = keys.value(forKey: "charactersIgnoringModfiers") as? String ?? ""
        let flags = (keys.value(forKey: "modifierFlags") as? NSNumber)?.uint64Value ?? 0
        
        sink?(.key(Self.key(characters: characters, unmodified: unmodified, flags: flags)))
    }
    
    @objc(recordingSession:didRecordApplicationActivated:)
    func recordingSession(_ session: AnyObject, didRecordApplicationActivated bundleID: NSString) {
        sink?(.activation(bundleID: bundleID as String))
    }
    
    @objc(recordingSession:didRecordOrientationChange:)
    func recordingSession(_ session: AnyObject, didRecordOrientationChange orientation: NSString) {
        sink?(.orientation(orientation as String))
    }
    
    // The rest of what a session calls its delegate with, which it calls without
    // asking whether the delegate answers: where the text goes and where the focus
    // is are no input, and a session's end is the recording's own.
    @objc(recordingSession:didRecordFirstResponderChangedWithApplicationSnapshot:)
    func recordingSession(_ session: AnyObject, didRecordFirstResponderChangedWithApplicationSnapshot application: AnyObject?) {}
    
    @objc(recordingSession:didRecordNativeFocusItemChangeAtTime:parameterSnapshot:applicationSnapshot:)
    func recordingSession(
        _ session: AnyObject,
        didRecordNativeFocusItemChangeAtTime time: AnyObject?,
        parameterSnapshot: AnyObject?,
        applicationSnapshot: AnyObject?
    ) {}
    
    @objc(recordingSessionDidDisconnect:)
    func recordingSessionDidDisconnect(_ session: AnyObject) {}
    
    // MARK: - Private
    // A character made with no modifier but shift holds the shift itself; a key
    // press-key names makes none to hold it.
    private static func key(characters: String, unmodified: String, flags: UInt64) -> InputEvent.Key {
        let held = modifierFlags.filter { _, flag in flags & flag != 0 }.map { modifier, _ in modifier }
        let shiftOnly = held.allSatisfy { modifier in modifier == .shift }
        let made = shiftOnly ? characters : unmodified
        
        if made.count == 1, let character = made.first, let name = keyNames[character] {
            return InputEvent.Key(key: name, modifiers: held)
        }
        
        return InputEvent.Key(key: made, modifiers: shiftOnly ? [] : held)
    }
}

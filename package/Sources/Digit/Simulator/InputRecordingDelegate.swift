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
    private let sink: @Sendable (InputEvent) -> Void
    
    // MARK: - Initializer
    init(sink: @escaping @Sendable (InputEvent) -> Void) {
        self.sink = sink
    }
    
    // MARK: - Public
    @objc(recordingSession:didRecordEvent:)
    func recordingSession(_ session: AnyObject, didRecordEvent event: NSObject) {
        let location = event.value(forKey: "startLocation") as? [String: Any]
        let point = location.flatMap { location -> Point? in
            guard let x = (location["x"] as? NSNumber)?.doubleValue, let y = (location["y"] as? NSNumber)?.doubleValue else { return nil }
            
            return Point(x: x, y: y)
        }
        let gesture = InputEvent.Gesture(
            names: event.value(forKey: "eventNames") as? [String] ?? [],
            time: Date(timeIntervalSinceReferenceDate: (event.value(forKey: "timestamp") as? NSNumber)?.doubleValue ?? 0),
            duration: (event.value(forKey: "duration") as? NSNumber)?.doubleValue ?? 0,
            point: point,
            element: (event.value(forKey: "startElementSnapshot") as? NSObject).map(Element.init(snapshot:)),
            application: (event.value(forKey: "startApplicationSnapshot") as? NSObject).map(Element.init(snapshot:))
        )
        
        sink(.gesture(gesture))
    }
    
    @objc(recordingSession:didRecordKeyEvents:)
    func recordingSession(_ session: AnyObject, didRecordKeyEvents keys: NSObject) {
        sink(
            .keys(
                InputEvent.Keys(
                    characters: keys.value(forKey: "characters") as? String ?? "",
                    unmodified: keys.value(forKey: "charactersIgnoringModfiers") as? String ?? "",
                    modifiers: (keys.value(forKey: "modifierFlags") as? NSNumber)?.uint64Value ?? 0
                )
            )
        )
    }
    
    @objc(recordingSession:didRecordApplicationActivated:)
    func recordingSession(_ session: AnyObject, didRecordApplicationActivated bundleID: NSString) {
        sink(.activation(bundleID: bundleID as String))
    }
    
    @objc(recordingSession:didRecordOrientationChange:)
    func recordingSession(_ session: AnyObject, didRecordOrientationChange orientation: NSString) {
        sink(.orientation(orientation as String))
    }
    
    // MARK: - Private
}

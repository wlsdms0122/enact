//
//  InputEvent.swift
//  Digit
//
//  Created by JSilver on 11/13/26.
//

import Foundation

// Input a device was given, as the device tells it, in the words Digit's own input
// operations take: a person's touch or key, or one Digit sent, alike.
public enum InputEvent: Sendable, Encodable {
    // A touch the device recognized, by the names it gave it (tap, long press,
    // swipe up, …), where it began, what answered there, and the application as it
    // was then. A touch that moved is told by the direction in its name; where it
    // ended is not given.
    public struct Gesture: Sendable {
        // MARK: - Property
        public let names: [String]
        public let time: Date
        public let duration: TimeInterval
        public let point: Point?
        public let element: Element?
        public let application: Element?
        
        // MARK: - Initializer
        public init(names: [String], time: Date, duration: TimeInterval, point: Point?, element: Element?, application: Element?) {
            self.names = names
            self.time = time
            self.duration = duration
            self.point = point
            self.element = element
            self.application = application
        }
        
        // MARK: - Public
        // MARK: - Private
    }
    
    // A key pressed on a hardware keyboard, as press-key takes it: by its name where
    // it has one (return, delete, up, …), else the character it made, with the
    // modifiers held, shift left out where the character already holds it.
    public struct Key: Sendable, Equatable {
        // MARK: - Property
        public let key: String
        public let modifiers: [Modifier]
        
        // MARK: - Initializer
        public init(key: String, modifiers: [Modifier]) {
            self.key = key
            self.modifiers = modifiers
        }
        
        // MARK: - Public
        // MARK: - Private
    }
    
    private enum CodingKeys: String, CodingKey {
        case kind
        case names
        case time
        case duration
        case point
        case element
        case application
        case button
        case key
        case modifiers
        case bundleID = "bundle_id"
        case orientation
    }
    
    case gesture(Gesture)
    case button(Button)
    case key(Key)
    // An application came to the front.
    case activation(bundleID: String)
    // The interface turned to the orientation named.
    case orientation(String)
    
    // MARK: - Public
    // A line of JSON names its kind beside what the kind holds, and a time as seconds
    // since 1970.
    public func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        switch self {
        case let .gesture(gesture):
            try container.encode("gesture", forKey: .kind)
            try container.encode(gesture.names, forKey: .names)
            try container.encode(gesture.time.timeIntervalSince1970, forKey: .time)
            try container.encode(gesture.duration, forKey: .duration)
            try container.encodeIfPresent(gesture.point.map { point in ["x": point.x, "y": point.y] }, forKey: .point)
            try container.encodeIfPresent(gesture.element, forKey: .element)
            try container.encodeIfPresent(gesture.application, forKey: .application)
        
        case let .button(button):
            try container.encode("button", forKey: .kind)
            try container.encode(button.rawValue, forKey: .button)
        
        case let .key(key):
            try container.encode("key", forKey: .kind)
            try container.encode(key.key, forKey: .key)
            try container.encode(key.modifiers.map(\.rawValue), forKey: .modifiers)
        
        case let .activation(bundleID):
            try container.encode("activation", forKey: .kind)
            try container.encode(bundleID, forKey: .bundleID)
        
        case let .orientation(orientation):
            try container.encode("orientation", forKey: .kind)
            try container.encode(orientation, forKey: .orientation)
        }
    }
    
    // MARK: - Private
}

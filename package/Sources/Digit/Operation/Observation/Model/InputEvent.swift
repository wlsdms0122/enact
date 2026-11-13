//
//  InputEvent.swift
//  Digit
//
//  Created by JSilver on 11/13/26.
//

import Foundation

// Input a device was given, as the device tells it: a person's touch or key, or one
// Digit sent, alike.
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
    
    // Keys typed on a hardware keyboard, with the characters they made, the ones they
    // make without the modifiers held, and the modifiers as the device's flags.
    public struct Keys: Sendable {
        // MARK: - Property
        public let characters: String
        public let unmodified: String
        public let modifiers: UInt64
        
        // MARK: - Initializer
        public init(characters: String, unmodified: String, modifiers: UInt64) {
            self.characters = characters
            self.unmodified = unmodified
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
        case characters
        case unmodified
        case modifiers
        case bundleID = "bundle_id"
        case orientation
    }
    
    case gesture(Gesture)
    case keys(Keys)
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
        
        case let .keys(keys):
            try container.encode("keys", forKey: .kind)
            try container.encode(keys.characters, forKey: .characters)
            try container.encode(keys.unmodified, forKey: .unmodified)
            try container.encode(keys.modifiers, forKey: .modifiers)
        
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

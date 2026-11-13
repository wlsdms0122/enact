//
//  InputEventTests.swift
//  DigitTests
//
//  Created by JSilver on 11/13/26.
//

import Foundation
import Testing
@testable import Digit

@Suite("A recorded input is a line of JSON naming its kind beside what the kind holds")
struct InputEventTests {
    // MARK: - Property
    // MARK: - Initializer
    // MARK: - Test
    @Test("a gesture holds its names, its time in seconds since 1970, where it began and what answered there")
    func aGestureIsALine() throws {
        // Given
        let sut = InputEvent.gesture(
            InputEvent.Gesture(
                names: ["tap"],
                time: Date(timeIntervalSince1970: 10),
                duration: 0.5,
                point: Point(x: 1, y: 2),
                element: Element(label: "General", role: .button, frame: Element.Frame(x: 0, y: 0, width: 4, height: 4)),
                application: nil
            )
        )
        
        // When
        let line = try line(of: sut)
        
        // Then
        #expect(line.hasPrefix(#"{"duration":0.5,"element":{"#))
        #expect(line.hasSuffix(#""kind":"gesture","names":["tap"],"point":{"x":1,"y":2},"time":10}"#))
    }
    
    @Test("a button, a key, an application in front and a turn are lines of their own kinds")
    func otherKindsAreLines() throws {
        // Given
        let events: [InputEvent] = [
            .button(.home),
            .key(InputEvent.Key(key: "c", modifiers: [.command])),
            .activation(bundleID: "com.apple.Preferences"),
            .orientation("landscape")
        ]
        
        // When
        let lines = try events.map(line(of:))
        
        // Then
        #expect(lines == [
            #"{"button":"home","kind":"button"}"#,
            #"{"key":"c","kind":"key","modifiers":["command"]}"#,
            #"{"bundle_id":"com.apple.Preferences","kind":"activation"}"#,
            #"{"kind":"orientation","orientation":"landscape"}"#
        ])
    }
    
    // MARK: - Private
    private func line(of event: InputEvent) throws -> String {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.sortedKeys, .withoutEscapingSlashes]
        
        return String(decoding: try encoder.encode(event), as: UTF8.self)
    }
}

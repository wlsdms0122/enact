//
//  RecordedInputTests.swift
//  EnactCLITests
//
//  Created by JSilver on 11/13/26.
//

import Foundation
import Testing
@testable import Digit
@testable import EnactCLI
@testable import EnactWarp

@Suite("A draft writes recorded input by the verb that does the same")
struct RecordedInputTests {
    // MARK: - Property
    // A row of keys across the bottom of the screen, the one under a tap not named.
    private let keys = [
        Snapshot(Element(label: "q", role: .key, frame: Element.Frame(x: 0, y: 600, width: 40, height: 50)), at: [0]),
        Snapshot(Element(label: "p", role: .key, frame: Element.Frame(x: 360, y: 750, width: 40, height: 50)), at: [1]),
        Snapshot(Element(label: "o", role: .key, frame: Element.Frame(x: 300, y: 600, width: 40, height: 50)), at: [2])
    ]
    
    // MARK: - Initializer
    // MARK: - Test
    @Test("a tap, a long press and a swipe are presses at where they began, a swipe by its direction")
    func gesturesArePresses() {
        // Given
        var sut = RecordedInput()
        
        // When
        let written = [gesture("tap", duration: 0.08), gesture("long press", duration: 1.02), gesture("swipe up", duration: 0.04)]
            .flatMap { event in sut.written(event, keys: []) }
        
        // Then
        guard written.count == 3,
            case let .tap(tapped) = written[0],
            case let .longPress(held, duration) = written[1],
            case let .swipe(swiped, direction, swipeDuration) = written[2]
        else {
            Issue.record("\(written) are not a tap, a long press and a swipe")
            
            return
        }
        
        #expect([tapped, held, swiped] == Array(repeating: Point(x: 10, y: 20), count: 3))
        #expect(duration == 1)
        #expect(direction == "up")
        #expect(swipeDuration == 0.1)
    }
    
    @Test("a button and a hardware key are pressed, and a gesture no verb does, a double tap among them, is a comment")
    func buttonsKeysAndOtherGestures() {
        // Given
        var sut = RecordedInput()
        let events: [InputEvent] = [
            .button(.home),
            .key(InputEvent.Key(key: "c", modifiers: [.command])),
            .key(InputEvent.Key(key: "home", modifiers: [])),
            gesture("double tap")
        ]
        
        // When
        let written = events.flatMap { event in sut.written(event, keys: []) }
        
        // Then
        #expect(written.map(flow) == [
            "{ call: { procedure: press_button, arguments: { button: { case: home } } } }",
            "{ call: { procedure: press_key, arguments: { key: \"c\", modifiers: [ { case: command } ] } } }",
            "{ call: { procedure: press_key, arguments: { key: \"home\" } } }",
            "# no verb does the gesture 'double tap' at 10.0,20.0"
        ])
    }
    
    @Test("keys tapped in a row are one text, written when input of another kind comes or the input ends, and a delete takes back what was typed")
    func keysTappedInARowAreOneText() {
        // Given
        var sut = RecordedInput()
        let typing = ["shift", "H", "i", "x", "delete", "space", "y"].map { label in key(label) }
        
        // When
        let written = typing.flatMap { event in sut.written(event, keys: keys) }
        let ended = sut.remaining()
        let again = sut.remaining()
        
        // Then
        #expect(written.isEmpty)
        #expect(ended.map(flow) == ["{ call: { procedure: type_text, arguments: { text: \"Hi y\" } } }"])
        #expect(again.isEmpty)
    }
    
    @Test("a key that types no text, as Go or a delete with nothing typed, is a tap on it after the text typed before")
    func aKeyThatTypesNoTextIsATap() {
        // Given
        var sut = RecordedInput()
        
        // When
        let typed = [key("a"), key("Go")].flatMap { event in sut.written(event, keys: keys) }
        let erased = sut.written(key("delete"), keys: keys)
        
        // Then
        guard typed.count == 2, case .tap = typed[1], erased.count == 1, case .tap = erased[0] else {
            Issue.record("\(typed) and \(erased) are not the text and the taps")
            
            return
        }
        
        #expect(flow(typed[0]) == "{ call: { procedure: type_text, arguments: { text: \"a\" } } }")
    }
    
    @Test("a tap that answers with no key is the look's key at its point, else changes the keyboard inside it, and is a tap outside it")
    func aTapThatAnswersWithNoKey() {
        // Given
        var sut = RecordedInput()
        let blank = Element(role: .container, frame: Element.Frame(x: 0, y: 0, width: 10, height: 10))
        
        // When
        let onKey = sut.written(gesture("tap", point: Point(x: 320, y: 620), element: blank), keys: keys)
        let inside = sut.written(gesture("tap", point: Point(x: 100, y: 700), element: blank), keys: keys)
        let typed = sut.remaining()
        let outside = sut.written(gesture("tap", point: Point(x: 30, y: 100), element: blank), keys: keys)
        
        // Then
        #expect(onKey.isEmpty)
        #expect(inside.isEmpty)
        #expect(typed.map(flow) == ["{ call: { procedure: type_text, arguments: { text: \"o\" } } }"])
        #expect(outside.count == 1)
    }
    
    // MARK: - Private
    private func gesture(
        _ name: String,
        point: Point? = Point(x: 10, y: 20),
        duration: Double = 0.1,
        element: Element? = nil
    ) -> InputEvent {
        .gesture(InputEvent.Gesture(names: [name], time: Date(), duration: duration, point: point, element: element, application: nil))
    }
    
    private func key(_ label: String) -> InputEvent {
        gesture("tap", point: Point(x: 20, y: 650), element: Element(label: label, role: .key, frame: Element.Frame(x: 0, y: 610, width: 40, height: 50)))
    }
    
    private func flow(_ operation: DraftOperation) -> String {
        switch operation {
        case let .call(call):
            call.flow
        
        case let .comment(comment):
            "# \(comment)"
        
        default:
            "\(operation)"
        }
    }
}

//
//  DraftOperationInputTests.swift
//  EnactCLITests
//
//  Created by JSilver on 11/13/26.
//

import Foundation
import Testing
@testable import Digit
@testable import EnactCLI

@Suite("A draft writes recorded input by the verb that does the same")
struct DraftOperationInputTests {
    // MARK: - Property
    private let keyboard = Element.Frame(x: 0, y: 600, width: 400, height: 200)
    
    // MARK: - Initializer
    // MARK: - Test
    @Test("a tap, a long press and a swipe are presses at where they began, a swipe by its direction")
    func gesturesArePresses() {
        // Given
        let tap = gesture("tap", duration: 0.08)
        let press = gesture("long press", duration: 1.02)
        let swipe = gesture("swipe up", duration: 0.04)
        
        // When
        let written = [tap, press, swipe].map(DraftOperation.written)
        
        // Then
        guard written.allSatisfy({ operations in operations.count == 1 }),
            case let .tap(tapped) = written[0][0],
            case let .longPress(held, duration) = written[1][0],
            case let .swipe(swiped, direction, swipeDuration) = written[2][0]
        else {
            Issue.record("\(written) are not a tap, a long press and a swipe")
            
            return
        }
        
        #expect([tapped, held, swiped] == Array(repeating: Point(x: 10, y: 20), count: 3))
        #expect(duration == 1)
        #expect(direction == "up")
        #expect(swipeDuration == 0.1)
    }
    
    @Test("the home button is pressed, the device's other halves of a press are not written, and no verb's gesture is a comment")
    func buttonsAndOtherGestures() {
        // Given
        let home = gesture("XCUIEventTypeMenuButtonDown", point: nil)
        let release = gesture("XCUIEventTypeACHomeUp", point: nil)
        let pinch = gesture("pinch")
        
        // When
        let written = [home, release, pinch].map(DraftOperation.written)
        
        // Then
        guard case let .call(call)? = written[0].first, case let .comment(comment)? = written[2].first else {
            Issue.record("\(written) are not a call and a comment")
            
            return
        }
        
        #expect(call.flow == "{ call: { procedure: press_button, arguments: { button: { case: home } } } }")
        #expect(written[1].isEmpty)
        #expect(comment == "no verb does the gesture 'pinch' at 10.0,20.0")
    }
    
    @Test(
        "a hardware key is pressed by what it makes, by its word where it has one, with the modifiers but shift",
        arguments: [
            ("a", "a", 0, #"{ key: "a" }"#),
            ("A", "a", 1 << 17, #"{ key: "A" }"#),
            ("\r", "\r", 0, #"{ key: "return" }"#),
            ("c", "c", 1 << 20, #"{ key: "c", modifiers: [ { case: command } ] }"#)
        ] as [(String, String, UInt64, String)]
    )
    func keysArePressed(characters: String, unmodified: String, modifiers: UInt64, arguments: String) {
        // Given
        let keys = InputEvent.keys(InputEvent.Keys(characters: characters, unmodified: unmodified, modifiers: modifiers))
        
        // When
        let written = DraftOperation.written(keys)
        
        // Then
        guard written.count == 1, case let .call(call) = written[0] else {
            Issue.record("\(written) is not a call")
            
            return
        }
        
        #expect(call.flow == "{ call: { procedure: press_key, arguments: \(arguments) } }")
    }
    
    @Test(
        "a tap on a software key types its character, or changes the keyboard, or is the key itself",
        arguments: [
            ("a", DraftOperation.KeyTap.character("a")),
            ("space", .character(" ")),
            ("shift", .changesKeyboard),
            ("numbers", .changesKeyboard),
            ("Go", .key("Go"))
        ]
    )
    func softwareKeys(label: String, tap: DraftOperation.KeyTap) {
        // Given
        let key = gesture("tap", element: Element(label: label, role: .key, frame: Element.Frame(x: 0, y: 610, width: 40, height: 50)))
        
        // When
        let sut = DraftOperation.keyTap(key, keyboard: keyboard)
        
        // Then
        #expect(sut == tap)
    }
    
    @Test("a tap that answers with no key changes the keyboard inside it, and is no key tap outside it")
    func anUnnamedTapInsideTheKeyboard() {
        // Given
        let blank = Element(role: .image, frame: Element.Frame(x: 0, y: 0, width: 10, height: 10))
        let inside = gesture("tap", point: Point(x: 30, y: 700), element: blank)
        let outside = gesture("tap", point: Point(x: 30, y: 100), element: blank)
        
        // When
        let taps = [inside, outside].map { event in DraftOperation.keyTap(event, keyboard: keyboard) }
        
        // Then
        #expect(taps == [.changesKeyboard, nil])
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
}

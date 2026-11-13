//
//  ObservedScreenInputTests.swift
//  EnactCLITests
//
//  Created by JSilver on 11/13/26.
//

import Foundation
import Testing
@testable import Digit
@testable import Enact
@testable import EnactCLI
@testable import EnactWarp

@Suite("A recorded press is named by the element of the look it landed on, while the look still shows the screen pressed")
struct ObservedScreenInputTests {
    // MARK: - Property
    private let screen = try! Screen(width: 400, height: 800)
    private let button = Element(label: "Continue", role: .button, frame: Element.Frame(x: 100, y: 700, width: 200, height: 50))
    private let text = Element(label: "Continue", role: .text, frame: Element.Frame(x: 160, y: 715, width: 80, height: 20))
    
    // MARK: - Initializer
    // MARK: - Test
    @Test("what accessibility answered is the element where the look has it")
    func theAnsweredElement() throws {
        // Given
        let sut = look([button])
        
        // When
        let pressed = sut.element(pressedBy: press(answering: button, application: nil))
        
        // Then
        #expect(try #require(pressed).snapshot.label == "Continue")
    }
    
    @Test("text inside a button names the button, where the application showed it there when it was pressed")
    func theElementHoldingTheAnswer() throws {
        // Given
        let sut = look([button])
        let application = Element(role: .container, frame: Element.Frame(x: 0, y: 0, width: 400, height: 800), children: [button])
        
        // When
        let pressed = sut.element(pressedBy: press(answering: text, application: application))
        
        // Then
        #expect(try #require(pressed).snapshot.role == .button)
    }
    
    @Test("a look of a screen that moved on before the press names nothing")
    func aLookOfAnotherScreen() {
        // Given
        let row = Element(label: "StandBy", role: .button, frame: Element.Frame(x: 0, y: 690, width: 400, height: 70))
        let field = Element(label: "Search", role: .field, frame: Element.Frame(x: 20, y: 710, width: 360, height: 30))
        let application = Element(role: .container, frame: Element.Frame(x: 0, y: 0, width: 400, height: 800), children: [field])
        let sut = look([row])
        
        // When
        let pressed = sut.element(pressedBy: press(answering: field, application: application))
        
        // Then
        #expect(pressed == nil)
    }
    
    @Test("the keyboard is where the look's keys stand")
    func theKeyboard() {
        // Given
        let keys = [
            Element(label: "q", role: .key, frame: Element.Frame(x: 5, y: 600, width: 40, height: 50)),
            Element(label: "m", role: .key, frame: Element.Frame(x: 300, y: 720, width: 40, height: 50))
        ]
        
        // When
        let sut = look(keys + [button])
        
        // Then
        #expect(sut.keyboard == Element.Frame(x: 5, y: 600, width: 335, height: 170))
        #expect(look([button]).keyboard == nil)
    }
    
    // MARK: - Private
    private func look(_ elements: [Element]) -> ObservedScreen {
        ObservedScreen(
            screen,
            elements: elements.enumerated().map { index, element in ObservedElement(Snapshot(element, at: [index]), text: element.label ?? "") }
        )
    }
    
    private func press(answering element: Element, application: Element?) -> InputEvent {
        .gesture(
            InputEvent.Gesture(
                names: ["tap"],
                time: Date(),
                duration: 0.1,
                point: Point(x: 200, y: 725),
                element: element,
                application: application
            )
        )
    }
}

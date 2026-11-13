//
//  CompositionTests.swift
//  EnactWarpTests
//
//  Created by JSilver on 11/1/26.
//

import Foundation
import Testing
import Warp
@testable import Digit
@testable import EnactWarp

@Suite("The library's compositions say with verbs what a scenario would")
struct CompositionTests {
    // MARK: - Property
    // MARK: - Initializer
    // MARK: - Test
    @Test("paste_text puts the text on the pasteboard and pastes it, so no key has to type it")
    func pasteTextPastes() async throws {
        // Given
        let sut = try DeviceStage()
        
        // When
        _ = try await sut.run(verbCall("paste_text", "{ text: \"안녕하세요\" }"))
        
        // Then
        #expect(sut.backend.performed.map(String.init(describing:)) == [
            "SetPasteboardOperator(text: \"안녕하세요\")",
            "PressKeyOperator(press: Digit.KeyPress(code: 25, shifted: false), modifiers: [Digit.Modifier.command])"
        ])
    }
    
    @Test("clear_text selects all the text and deletes it")
    func clearTextSelectsAllAndDeletes() async throws {
        // Given
        let sut = try DeviceStage()
        
        // When
        _ = try await sut.run(verbCall("clear_text"))
        
        // Then
        #expect(sut.backend.performed.map(String.init(describing:)) == [
            "PressKeyOperator(press: Digit.KeyPress(code: 4, shifted: false), modifiers: [Digit.Modifier.command])",
            "PressKeyOperator(press: Digit.KeyPress(code: 42, shifted: false), modifiers: [])"
        ])
    }
    
    @Test("wait_for returns the first element in reading order that where holds of")
    func waitForReturnsTheFirstMatch() async throws {
        // Given
        let sut = try DeviceStage(elements: [
            Element(label: "Cancel", role: .button, frame: Element.Frame(x: 10, y: 300, width: 80, height: 40)),
            Element(label: "Save", role: .button, frame: Element.Frame(x: 110, y: 300, width: 80, height: 40)),
            Element(label: "Save", role: .button, frame: Element.Frame(x: 210, y: 300, width: 80, height: 40))
        ])
        let arguments = "{ where: \(labeled("Save")), debounce: 0.1 }"
        
        // When
        let result = try await sut.run(verbCall("wait_for", arguments, returns: "Enact.Snapshot"))
        
        // Then
        guard case let .struct(held) = result, case let .struct(frame) = held["frame"] else {
            Issue.record("\(result) is not a snapshot")
            
            return
        }
        
        #expect(held["label"] == .string("Save"))
        #expect(frame["x"] == .double(110))
    }
    
    @Test("wait_for that never sees what it waits for is timed_out")
    func waitForTimesOut() async throws {
        // Given
        let sut = try DeviceStage(elements: [
            Element(label: "Cancel", role: .button, frame: Element.Frame(x: 10, y: 300, width: 80, height: 40))
        ])
        let arguments = "{ where: \(labeled("Save")), timeout: 0.3, debounce: 0.1 }"
        
        // When
        let refusal = await #expect(throws: StepFailure.self) {
            _ = try await sut.run(verbCall("wait_for", arguments, returns: "Enact.Snapshot"))
        }
        
        // Then
        #expect(try #require(refusal).kind == .timedOut)
    }
    
    @Test("scroll_to that sees what it scrolls to whole returns it without dragging")
    func scrollToReturnsWhatIsShown() async throws {
        // Given
        let sut = try DeviceStage(elements: [
            Element(label: "Save", role: .button, frame: Element.Frame(x: 110, y: 300, width: 80, height: 40))
        ])
        let arguments = "{ where: \(labeled("Save")), on: \(snapshotLiteral(role: "container", frame: (0, 100, 400, 600))), direction: { case: up }, debounce: 0.1 }"
        
        // When
        let result = try await sut.run(verbCall("scroll_to", arguments, returns: "Enact.Snapshot"))
        
        // Then
        guard case let .struct(held) = result else {
            Issue.record("\(result) is not a snapshot")
            
            return
        }
        
        #expect(held["label"] == .string("Save"))
        #expect(!sut.backend.performed.contains { operation in operation is DragOperator })
    }
    
    @Test("scroll_to drags inside the snapshot each round it does not see what it scrolls to whole, until timed_out", arguments: [
        Element(label: "Cancel", role: .button, frame: Element.Frame(x: 10, y: 300, width: 80, height: 40)),
        Element(label: "Save", role: .button, frame: Element.Frame(x: 10, y: 680, width: 80, height: 40))
    ])
    func scrollToDragsUntilTimedOut(_ shown: Element) async throws {
        // Given
        let sut = try DeviceStage(elements: [shown])
        let arguments = "{ where: \(labeled("Save")), on: \(snapshotLiteral(role: "container", frame: (0, 100, 400, 600))), direction: { case: up }, timeout: 0.5, debounce: 0.1 }"
        
        // When
        let refusal = await #expect(throws: StepFailure.self) {
            _ = try await sut.run(verbCall("scroll_to", arguments, returns: "Enact.Snapshot"))
        }
        
        // Then
        #expect(try #require(refusal).kind == .timedOut)
        #expect(sut.backend.performed.contains { operation in operation is DragOperator })
    }
    
    @Test("scroll_to drags what it scrolls to toward the middle once the tree holds it, cut or off the screen", arguments: [
        (Element.Frame(x: 10, y: 600, width: 80, height: 300), "start: Digit.Point(x: 200.0, y: 575.0), end: Digit.Point(x: 200.0, y: 225.0)"),
        (Element.Frame(x: 10, y: 50, width: 80, height: 300), "start: Digit.Point(x: 200.0, y: 300.0), end: Digit.Point(x: 200.0, y: 500.0)"),
        (Element.Frame(x: 10, y: 2000, width: 80, height: 40), "start: Digit.Point(x: 200.0, y: 580.0), end: Digit.Point(x: 200.0, y: 220.0)")
    ])
    func scrollToDragsWhatItHoldsTowardTheMiddle(_ frame: Element.Frame, _ stroke: String) async throws {
        // Given
        let sut = try DeviceStage(elements: [Element(label: "Save", role: .button, frame: frame)])
        let arguments = "{ where: \(labeled("Save")), on: \(snapshotLiteral(role: "container", frame: (0, 100, 400, 600))), direction: { case: down }, timeout: 0.3, debounce: 0.1 }"
        
        // When
        let refusal = await #expect(throws: StepFailure.self) {
            _ = try await sut.run(verbCall("scroll_to", arguments, returns: "Enact.Snapshot"))
        }
        
        // Then
        #expect(try #require(refusal).kind == .timedOut)
        #expect(sut.backend.performed.map(String.init(describing:)).first == "DragOperator(stroke: Digit.Stroke(\(stroke), duration: 0.2))")
    }
    
    @Test(
        "displayed_text is a field's value, a heading's or a text's label or else its value, and anything else's label",
        arguments: [
            ("field", "Name", "typed", "typed"),
            ("secureField", "Password", "••", "••"),
            ("button", "Save", "1", "Save"),
            ("field", "Name", nil, ""),
            ("heading", "Title", "Other", "Title"),
            ("heading", "", "Title", "Title"),
            ("text", nil, "Body", "Body"),
            ("toggle", "", "1", "")
        ] as [(String, String?, String?, String)]
    )
    func textReadsWhatTheRoleShows(_ role: String, _ label: String?, _ value: String?, _ shown: String) async throws {
        // Given
        let sut = try DeviceStage()
        
        // When
        let result = try await sut.run(
            verbCall("displayed_text", "{ of: \(snapshotLiteral(role: role, label: label, value: value)) }", returns: "String")
        )
        
        // Then
        #expect(result == .string(shown))
        #expect(sut.backend.performed.isEmpty)
    }
    
    @Test("screen_point turns fractions of a snapshot's frame, outside it too, into fractions of the screen")
    func screenPointTurnsFramePointsIntoScreenPoints() async throws {
        // Given
        let sut = try DeviceStage()
        let screen = "{ struct: { width: 400, height: 800, elements: [] } }"
        let at = "{ struct: { x: 0.5, y: 2 } }"
        
        // When
        let result = try await sut.run(
            verbCall("screen_point", "{ on: \(snapshotLiteral()), at: \(at), screen: \(screen) }", returns: "Enact.Point")
        )
        
        // Then
        guard case let .struct(point) = result else {
            Issue.record("\(result) is not a point")
            
            return
        }
        
        #expect(point["x"] == .double(0.35))
        #expect(point["y"] == .double(0.35))
        #expect(sut.backend.performed.isEmpty)
    }
    
    // MARK: - Private
    private func labeled(_ label: String) -> String {
        "{ closure: { parameters: [ one: Enact.Snapshot ], result: { of: { ref: one.label }, is: \(label) } } }"
    }
}

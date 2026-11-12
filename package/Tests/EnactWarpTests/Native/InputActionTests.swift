//
//  InputActionTests.swift
//  EnactWarpTests
//
//  Created by JSilver on 10/31/26.
//

import Foundation
import Testing
import Warp
@testable import EnactWarp

@Suite("Input verbs press, type and stroke where their arguments say")
struct InputActionTests {
    // MARK: - Property
    // MARK: - Initializer
    // MARK: - Test
    @Test("each input verb hands the device the operation its arguments say", arguments: [
        ("tap", "{ on: \(snapshotLiteral()) }", "TapOperator(point: Digit.Point(x: 140.0, y: 220.0))"),
        (
            "tap",
            "{ on: \(snapshotLiteral()), at: { struct: { x: 0.25, y: 1 } } }",
            "TapOperator(point: Digit.Point(x: 120.0, y: 240.0))"
        ),
        ("tap_point", "{ at: { struct: { x: 0.25, y: 0.5 } } }", "TapOperator(point: Digit.Point(x: 100.0, y: 400.0))"),
        ("long_press", "{ on: \(snapshotLiteral()) }", "LongPressOperator(point: Digit.Point(x: 140.0, y: 220.0), duration: 0.5)"),
        ("type_text", "{ text: hello }", "TypeTextOperator(text: \"hello\")"),
        (
            "move_slider",
            "{ on: \(snapshotLiteral(role: "slider", value: "50%", track: (100, 210, 200, 20))), value: 0.75 }",
            "MoveSliderOperator(frame: Digit.Element.Frame(x: 100.0, y: 210.0, width: 200.0, height: 20.0), from: 0.5, to: 0.75, duration: 0.4)"
        ),
        (
            "press_key",
            "{ key: return, modifiers: [ { case: command }, { case: shift } ] }",
            "PressKeyOperator(press: Digit.KeyPress(code: 40, shifted: false), modifiers: [Digit.Modifier.command, Digit.Modifier.shift])"
        ),
        ("press_button", "{ button: { case: applePay } }", "PressButtonOperator(button: Digit.Button.applePay)"),
        (
            "swipe",
            "{ direction: { case: up } }",
            "SwipeOperator(stroke: Digit.Stroke(start: Digit.Point(x: 200.0, y: 640.0), end: Digit.Point(x: 200.0, y: 160.0), duration: 0.2))"
        ),
        (
            "swipe_between",
            "{ from: { struct: { x: 0.5, y: 0.9 } }, to: { struct: { x: 0.5, y: 0.1 } } }",
            "SwipeOperator(stroke: Digit.Stroke(start: Digit.Point(x: 200.0, y: 720.0), end: Digit.Point(x: 200.0, y: 80.0), duration: 0.2))"
        ),
        (
            "swipe_on",
            "{ on: \(snapshotLiteral()), direction: { case: up } }",
            "SwipeOperator(stroke: Digit.Stroke(start: Digit.Point(x: 140.0, y: 232.0), end: Digit.Point(x: 140.0, y: 208.0), duration: 0.2))"
        ),
        (
            "swipe_on",
            "{ on: \(snapshotLiteral(frame: (0, 700, 400, 200))), direction: { case: up } }",
            "SwipeOperator(stroke: Digit.Stroke(start: Digit.Point(x: 200.0, y: 780.0), end: Digit.Point(x: 200.0, y: 720.0), duration: 0.2))"
        ),
        (
            "drag",
            "{ from: { struct: { x: 0, y: 0 } }, to: { struct: { x: 1, y: 1 } }, duration: 1 }",
            "DragOperator(stroke: Digit.Stroke(start: Digit.Point(x: 0.0, y: 0.0), end: Digit.Point(x: 400.0, y: 800.0), duration: 1.0))"
        ),
        ("respond_biometric", nil, "RespondBiometricOperator(outcome: Digit.BiometricOutcome.match)")
    ])
    func eachVerbHandsTheDeviceItsOperation(_ procedure: String, _ arguments: String?, _ expected: String) async throws {
        // Given
        let sut = try DeviceStage()
        
        // When
        let result = try await sut.run(verbCall(procedure, arguments))
        
        // Then
        #expect(result == .null)
        #expect(sut.backend.performed.map(String.init(describing:)) == [expected])
    }
    
    @Test("a point is fractions from 0 to 1", arguments: [
        ("tap", "{ on: \(snapshotLiteral()), at: { struct: { x: 1.5, y: 0.5 } } }"),
        ("swipe_between", "{ from: { struct: { x: -0.1, y: 0 } }, to: { struct: { x: 1, y: 1 } } }")
    ])
    func aPointOutsideIsRefused(_ procedure: String, _ arguments: String) async throws {
        // Given
        let sut = try DeviceStage()
        
        // When
        let refusal = await #expect(throws: StepFailure.self) {
            _ = try await sut.run(verbCall(procedure, arguments))
        }
        
        // Then
        #expect(try #require(refusal).kind == .argumentRefused)
        #expect(sut.backend.performed.isEmpty)
    }
    
    @Test("a key the keyboard does not have is refused with the keys there are")
    func anUnknownKeyNamesTheKeysThereAre() async throws {
        // Given
        let sut = try DeviceStage()
        
        // When
        let refusal = await #expect(throws: StepFailure.self) {
            _ = try await sut.run(verbCall("press_key", "{ key: hyper }"))
        }
        
        // Then
        let failure = try #require(refusal)
        
        #expect(failure.kind == .argumentRefused)
        #expect(failure.detail.contains("page-up"), "\(failure.detail)")
    }
    
    @Test("a word its set does not have is refused by the build, and the device is not touched", arguments: [
        ("press_button", "{ button: { case: hoem } }"),
        ("swipe", "{ direction: { case: north } }"),
        ("reset_privacy", "{ service: [ { case: phots } ] }")
    ])
    func anUnknownWordIsRefusedByTheBuild(_ procedure: String, _ arguments: String) async throws {
        // Given
        let sut = try DeviceStage()
        
        // When / Then
        await #expect(throws: BuildRefused.self) {
            _ = try await sut.run(verbCall(procedure, arguments))
        }
        #expect(sut.backend.performed.isEmpty)
    }
    
    @Test("a press on a disabled snapshot, or one landing off the screen, is refused, and the device is not touched", arguments: [
        ("tap", "{ on: \(snapshotLiteral(enabled: false)) }", "not enabled"),
        ("tap", "{ on: \(snapshotLiteral(frame: (100, 900, 80, 40))) }", "off the screen"),
        ("tap", "{ on: \(snapshotLiteral(frame: (380, 200, 80, 40))), at: { struct: { x: 0.75, y: 0.5 } } }", "off the screen"),
        ("long_press", "{ on: \(snapshotLiteral(frame: (100, -100, 80, 40))) }", "off the screen"),
        ("swipe_on", "{ on: \(snapshotLiteral(frame: (0, 900, 400, 200))), direction: { case: up } }", "off the screen")
    ])
    func anUnfitPressIsRefused(_ procedure: String, _ arguments: String, _ said: String) async throws {
        // Given
        let sut = try DeviceStage()
        
        // When
        let refusal = await #expect(throws: StepFailure.self) {
            _ = try await sut.run(verbCall(procedure, arguments))
        }
        
        // Then
        let failure = try #require(refusal)
        
        #expect(failure.kind == .referenceUnfit)
        #expect(failure.detail.contains(said), "\(failure.detail)")
        #expect(sut.backend.performed.isEmpty)
    }
    
    @Test("a slider is moved along its rail from where its value says the thumb is", arguments: [
        snapshotLiteral(role: "slider", value: "50%"),
        snapshotLiteral(role: "slider", value: "loud", track: (100, 210, 200, 20))
    ])
    func aSliderNeedsItsRailAndPosition(_ snapshot: String) async throws {
        // Given
        let sut = try DeviceStage()
        
        // When
        let refusal = await #expect(throws: StepFailure.self) {
            _ = try await sut.run(verbCall("move_slider", "{ on: \(snapshot), value: 1 }"))
        }
        
        // Then
        #expect(try #require(refusal).kind == .referenceUnfit)
    }
    
    // MARK: - Private
}

//
//  SimulatorInput.swift
//  Digit
//
//  Created by JSilver on 8/16/26.
//

import FBSimulatorControl
import Foundation

struct SimulatorInput {
    // MARK: - Property
    private static let swipeDelta: Double = 10
    private static let dragDelta: Double = 1
    private static let dragHold: TimeInterval = 0.2
    
    var implementations: [Implementation] {
        var implementations: [Implementation] = [
            .perform(tap),
            .perform(longPress),
            .perform(swipe),
            .perform(drag),
            .perform(typeText),
            .perform(pressKey),
            .perform(pressButton),
            .perform(moveSlider)
        ]
        
        if let biometric = applePrivate.biometric {
            implementations.append(.perform(respondBiometric(biometric)))
        }
        
        return implementations
    }
    
    private let simulator: Simulator
    private let applePrivate: ApplePrivate
    
    // MARK: - Initializer
    init(simulator: Simulator) {
        self.simulator = simulator
        self.applePrivate = ApplePrivate(simulator: simulator)
    }
    
    // MARK: - Public
    // MARK: - Private
    private func tap(_ operation: TapOperator) async throws {
        try await send(.tapAt(x: operation.point.x, y: operation.point.y))
    }
    
    private func longPress(_ operation: LongPressOperator) async throws {
        try await send(
            .tapAt(x: operation.point.x, y: operation.point.y, duration: operation.duration)
        )
    }
    
    private func swipe(_ operation: SwipeOperator) async throws {
        try await send(.swipe(operation.stroke, delta: Self.swipeDelta))
    }
    
    private func drag(_ operation: DragOperator) async throws {
        try await send(.drag(operation.stroke, delta: Self.dragDelta, hold: Self.dragHold))
    }
    
    private func typeText(_ operation: TypeTextOperator) async throws {
        try await SoftwareKeyboard(simulator: simulator, hid: simulator.hid.connect()).type(operation.text)
    }
    
    private func pressKey(_ operation: PressKeyOperator) async throws {
        let hid = try await simulator.hid.connect()
        
        try await hold(operation.modifiers.map(\.code), on: hid) {
            try await send(operation.press, on: hid)
        }
    }
    
    private func pressButton(_ operation: PressButtonOperator) async throws {
        try await send(.shortButtonPress(SimulatorHIDButton(operation.button)))
    }
    
    private func moveSlider(_ operation: MoveSliderOperator) async throws {
        guard let stroke = try operation.travel() else { return }
        
        try await send(.swipe(stroke, delta: Self.dragDelta))
    }
    
    private func respondBiometric(
        _ biometric: Biometric
    ) -> (RespondBiometricOperator) async throws -> Void {
        { [applePrivate] operation in
            try applePrivate.respond(to: biometric, with: operation.outcome)
        }
    }
    
    private func send(_ event: SimulatorHIDEvent) async throws {
        try await send(event, on: simulator.hid.connect())
    }
    
    private func send(_ event: SimulatorHIDEvent, on hid: SimulatorHID) async throws {
        try await hid.send(event: event, logger: simulator.logger)
    }
    
    private func send(_ press: KeyPress, on hid: SimulatorHID) async throws {
        try await hold(press.shifted ? [Modifier.shift.code] : [], on: hid) {
            try await send(.shortKeyPress(press.code), on: hid)
        }
    }
    
    private func hold(
        _ modifiers: [UInt32],
        on hid: SimulatorHID,
        _ body: () async throws -> Void
    ) async throws {
        var pressed: [UInt32] = []
        
        do {
            for modifier in modifiers {
                try await send(.keyboard(direction: .down, keyCode: modifier), on: hid)
                
                pressed.append(modifier)
            }
            
            try await body()
        } catch {
            _ = await release(pressed, on: hid)
            
            throw error
        }
        
        if let failure = await release(pressed, on: hid) { throw failure }
    }
    
    private func release(_ modifiers: [UInt32], on hid: SimulatorHID) async -> Error? {
        var failure: Error?
        
        for modifier in modifiers.reversed() {
            do {
                try await send(.keyboard(direction: .up, keyCode: modifier), on: hid)
            } catch {
                failure = failure ?? error
            }
        }
        
        return failure
    }
}

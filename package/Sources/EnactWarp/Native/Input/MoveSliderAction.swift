//
//  MoveSliderAction.swift
//  EnactWarp
//
//  Created by JSilver on 10/31/26.
//

import Digit
import Foundation
import Warp

struct MoveSliderAction: EnactAction {
    enum Parameters: Int, ParameterSet {
        case on
        case value
        
        // MARK: - Property
        var declared: Parameter {
            switch self {
            case .on:
                Parameter(name: "on")
            
            case .value:
                Parameter(name: "value")
            }
        }
        
        // MARK: - Initializer
        // MARK: - Public
        // MARK: - Private
    }
    
    // MARK: - Property
    static let operations: Set<Digit.Operation> = [.moveSlider]
    
    // MARK: - Initializer
    // MARK: - Public
    func act(_ invocation: Invocation<Self>, in environment: EnactEnvironment) async throws -> Warp.Value {
        let snapshot = try invocation.snapshot(.on)
        
        guard let track = snapshot.track else {
            throw StepFailure(.referenceUnfit, "the snapshot has no track: the look saw no slider rail there")
        }
        
        try await environment.device.run(
            MoveSliderOperator(
                frame: track,
                from: try position(of: snapshot),
                to: try invocation.double(.value),
                duration: 0.4
            )
        )
        
        return .null
    }
    
    // MARK: - Private
    // Where the thumb stands, read off the value the screen gives a slider: a
    // fraction or a percentage.
    private func position(of snapshot: Snapshot) throws -> Double {
        let text = (snapshot.value ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        
        if text.hasSuffix("%"), let percent = Double(text.dropLast()) { return percent / 100 }
        if let fraction = Double(text) { return fraction }
        
        throw StepFailure(
            .referenceUnfit,
            "the snapshot's value does not say where the slider is, a fraction or a percentage, but "
                + (text.isEmpty ? "nothing" : "'\(text)'")
        )
    }
}

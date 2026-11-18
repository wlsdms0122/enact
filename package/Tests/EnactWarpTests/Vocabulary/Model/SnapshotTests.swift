//
//  SnapshotTests.swift
//  EnactWarpTests
//
//  Created by JSilver on 10/31/26.
//

import Foundation
import Testing
import Warp
@testable import Digit
@testable import EnactWarp

@Suite("A snapshot is an element as one look saw it")
struct SnapshotTests {
    // MARK: - Property
    // MARK: - Initializer
    // MARK: - Test
    @Test("text is trimmed, and only a slider carries a rail, its innermost slider's frame")
    func aSnapshotOfAnElement() {
        // Given
        let rail = Element(role: .slider, frame: Element.Frame(x: 10, y: 20, width: 200, height: 4))
        let slider = Element(
            id: " volume ",
            label: "Volume\n",
            value: "50%",
            role: .slider,
            frame: Element.Frame(x: 0, y: 0, width: 220, height: 44),
            children: [rail]
        )
        let button = Element(label: "Save", role: .button, frame: Element.Frame(x: 0, y: 0, width: 80, height: 40))
        
        // When
        let sut = (slider: Snapshot(slider, at: [0]), button: Snapshot(button, at: [1]))
        
        // Then
        #expect(sut.slider.id == "volume")
        #expect(sut.slider.label == "Volume")
        #expect(sut.slider.track == rail.frame)
        #expect(sut.button.track == nil)
    }
    
    @Test("a snapshot crosses into a scenario and back as it was")
    func aSnapshotRoundTrips() throws {
        // Given
        let sut = Snapshot(
            id: nil,
            label: "Save",
            value: nil,
            role: .secureField,
            enabled: false,
            actions: ["activate"],
            frame: Element.Frame(x: 1, y: 2, width: 3, height: 4),
            track: nil,
            indexPath: [0, 2]
        )
        
        // When
        let crossed = try Snapshot(try Warp.Value(sut))
        
        // Then
        #expect(crossed == sut)
    }
    
    // MARK: - Private
}

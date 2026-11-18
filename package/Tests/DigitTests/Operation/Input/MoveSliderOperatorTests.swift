//
//  MoveSliderOperatorTests.swift
//  DigitTests
//
//  Created by JSilver on 8/16/26.
//

import Testing
@testable import Digit

@Suite("Moving a slider stays on its track")
struct MoveSliderOperatorTests {
    // MARK: - Property
    // MARK: - Initializer
    // MARK: - Test
    @Test("a position off the track is refused", arguments: [(0.0, 1.5), (-0.1, 0.5), (0.0, 1e300)])
    func positionsOffTheTrackAreRefused(from: Double, to: Double) {
        // Given
        let frame = Element.Frame(x: 0, y: 0, width: 100, height: 40)
        
        // When / Then
        #expect(throws: DigitError.self) {
            try MoveSliderOperator(frame: frame, from: from, to: to, duration: 0.4)
        }
    }
    
    @Test("a track no wider than the knob is refused")
    func slidersNeedRoomForTheKnobToMove() {
        // Given
        let radius = MoveSliderOperator.knobRadius
        
        // When / Then
        for width in [radius * 2, 0] {
            #expect(throws: DigitError.self) {
                try MoveSliderOperator(
                    frame: Element.Frame(x: 0, y: 0, width: width, height: 40),
                    from: 0,
                    to: 1,
                    duration: 0.4
                )
            }
        }
        #expect(throws: Never.self) {
            try MoveSliderOperator(
                frame: Element.Frame(x: 0, y: 0, width: radius * 2 + 1, height: 40),
                from: 0,
                to: 1,
                duration: 0.4
            )
        }
    }
    
    @Test("a slider already where it should be has no travel")
    func aSliderAlreadyThereHasNothingToCarryOut() throws {
        // Given
        let track = Element.Frame(x: 0, y: 0, width: 300, height: 40)
        let sut = try MoveSliderOperator(frame: track, from: 0.5, to: 0.5, duration: 0.4)
        
        // When
        let travel = try sut.travel()
        
        // Then
        #expect(travel == nil)
    }
    
    @Test("a knob sent further along travels right")
    func aKnobSentFurtherGoesRight() throws {
        // Given
        let track = Element.Frame(x: 0, y: 0, width: 300, height: 40)
        let sut = try MoveSliderOperator(frame: track, from: 0.2, to: 0.8, duration: 0.4)
        
        // When
        let stroke = try #require(try sut.travel())
        
        // Then
        #expect(stroke.start.x < stroke.end.x)
    }
}

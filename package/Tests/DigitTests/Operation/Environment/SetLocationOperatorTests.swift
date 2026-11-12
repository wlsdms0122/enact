//
//  SetLocationOperatorTests.swift
//  DigitTests
//
//  Created by JSilver on 11/5/26.
//

import Testing
@testable import Digit

@Suite("A move along waypoints has somewhere to go and a pace to go at")
struct SetLocationOperatorTests {
    // MARK: - Property
    // MARK: - Initializer
    // MARK: - Test
    @Test("fewer than two waypoints are refused")
    func oneWaypointIsRefused() throws {
        // Given
        let waypoint = try Coordinate(latitude: 37.5, longitude: 127)
        
        // When
        let refusal = #expect(throws: DigitError.self) {
            try SetLocationOperator(.waypoints([waypoint], speed: nil))
        }
        
        // Then
        #expect(refusal?.description == "waypoints holds 1, and needs at least 2")
    }
    
    @Test("a speed that is not a number more than zero is refused", arguments: [0, -1, Double.nan, Double.infinity])
    func aStillSpeedIsRefused(_ speed: Double) throws {
        // Given
        let waypoints = [try Coordinate(latitude: 37.5, longitude: 127), try Coordinate(latitude: 37.6, longitude: 127)]
        
        // When / Then
        #expect(throws: DigitError.self) {
            try SetLocationOperator(.waypoints(waypoints, speed: speed))
        }
    }
}

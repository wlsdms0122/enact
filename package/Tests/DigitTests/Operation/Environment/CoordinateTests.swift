//
//  CoordinateTests.swift
//  DigitTests
//
//  Created by JSilver on 8/16/26.
//

import Testing
@testable import Digit

@Suite("A coordinate names a place on Earth")
struct CoordinateTests {
    // MARK: - Property
    // MARK: - Initializer
    // MARK: - Test
    @Test("a latitude or longitude off the globe is refused", arguments: [(91.0, 0.0), (0.0, -181.0)])
    func offTheGlobeIsRefused(latitude: Double, longitude: Double) {
        // When / Then
        #expect(throws: DigitError.self) { try Coordinate(latitude: latitude, longitude: longitude) }
    }
    
    @Test("a place on Earth is accepted")
    func aPlaceIsAccepted() {
        // When / Then
        #expect(throws: Never.self) { try Coordinate(latitude: 37.5, longitude: 127.0) }
    }
}

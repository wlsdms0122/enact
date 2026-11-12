//
//  Coordinate.swift
//  Digit
//
//  Created by JSilver on 8/16/26.
//

import Foundation

public struct Coordinate: Sendable {
    // MARK: - Property
    public let latitude: Double
    public let longitude: Double
    
    // MARK: - Initializer
    public init(latitude: Double, longitude: Double) throws {
        guard (-90.0...90.0).contains(latitude) else {
            throw DigitError.outOfInterval(field: "latitude", value: latitude, allowed: -90...90)
        }
        
        guard (-180.0...180.0).contains(longitude) else {
            throw DigitError.outOfInterval(
                field: "longitude",
                value: longitude,
                allowed: -180...180
            )
        }
        
        self.latitude = latitude
        self.longitude = longitude
    }
    
    // MARK: - Public
    // MARK: - Private
}

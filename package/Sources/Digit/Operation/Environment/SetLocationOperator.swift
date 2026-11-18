//
//  SetLocationOperator.swift
//  Digit
//
//  Created by JSilver on 8/16/26.
//

import Foundation

public struct SetLocationOperator: Operator {
    // MARK: - Property
    public static let operation = Operation.setLocation
    
    public let update: LocationUpdate
    
    // MARK: - Initializer
    public init(_ update: LocationUpdate) throws {
        if case let .waypoints(waypoints, speed) = update {
            guard waypoints.count >= 2 else {
                throw DigitError.tooFew(field: "waypoints", count: waypoints.count, least: 2)
            }
            
            if let speed {
                guard speed.isFinite, speed > 0 else { throw DigitError.notPositive(field: "speed", value: speed) }
            }
        }
        
        self.update = update
    }
    
    // MARK: - Public
    // MARK: - Private
}

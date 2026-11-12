//
//  LocationUpdate.swift
//  Digit
//
//  Created by JSilver on 8/16/26.
//

import Foundation

public enum LocationUpdate: Sendable {
    case fixed(Coordinate)
    case scenario(String)
    // Moving from each waypoint to the next at a speed in metres per second,
    // the simulator's own where none is given.
    case waypoints([Coordinate], speed: Double?)
    case clear
}

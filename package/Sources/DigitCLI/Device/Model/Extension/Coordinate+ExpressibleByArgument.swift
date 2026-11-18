//
//  Coordinate+ExpressibleByArgument.swift
//  DigitCLI
//
//  Created by JSilver on 11/5/26.
//

import ArgumentParser
import Digit

// Written as simctl writes a waypoint, `latitude,longitude`.
extension Coordinate: ExpressibleByArgument {
    public init?(argument: String) {
        let parts = argument.split(separator: ",", omittingEmptySubsequences: false)
        
        guard parts.count == 2,
            let latitude = Double(parts[0].trimmingCharacters(in: .whitespaces)),
            let longitude = Double(parts[1].trimmingCharacters(in: .whitespaces)),
            let coordinate = try? Coordinate(latitude: latitude, longitude: longitude)
        else {
            return nil
        }
        
        self = coordinate
    }
}

//
//  SetLocation.swift
//  DigitCLI
//
//  Created by JSilver on 8/16/26.
//

import ArgumentParser
import Digit
import Foundation

package struct SetLocation: DeviceCommand {
    // MARK: - Property
    package static let configuration = CommandConfiguration(
        commandName: Operation.setLocation.rawValue,
        abstract: "Set what the device reports as its whereabouts.",
        discussion: """
            One of: a point (--latitude/--longitude), a named route (--scenario) \
            the runtime ships, waypoints to move along (--waypoint, at --speed), \
            or --clear to hand location back to the device. \
            A wrong route name is refused with the ones this device has. The \
            list is empty until it is booted.
            """
    )
    
    @OptionGroup package var target: DeviceOption
    @Option package var latitude: Double?
    @Option package var longitude: Double?
    @Option(help: "a named route, e.g. freeway-drive (the device lists its own)")
    package var scenario: String?
    @Option(help: "latitude,longitude to move through, in order (repeatable, two or more)")
    package var waypoint: [Coordinate] = []
    @Option(help: "metres per second along the waypoints") package var speed: Double?
    @Flag(help: "stop simulating a location") package var clear: Bool = false
    
    // MARK: - Initializer
    package init() {}
    
    // MARK: - Public
    package func perform(on device: Device) async throws -> Empty {
        try await device.run(try SetLocationOperator(update()))
        
        return Empty()
    }
    
    package func update() throws -> LocationUpdate {
        let point = latitude != nil || longitude != nil
        
        guard [point, scenario != nil, !waypoint.isEmpty, clear].filter({ $0 }).count == 1 else {
            throw ValidationError("give exactly one of a point, --scenario, --waypoint or --clear")
        }
        
        guard speed == nil || !waypoint.isEmpty else {
            throw ValidationError("--speed is the pace along --waypoint")
        }
        
        if clear { return .clear }
        if let scenario { return .scenario(scenario) }
        if !waypoint.isEmpty { return .waypoints(waypoint, speed: speed) }
        
        guard let latitude, let longitude else {
            throw ValidationError("a point needs both --latitude and --longitude")
        }
        
        return .fixed(try Coordinate(latitude: latitude, longitude: longitude))
    }
    
    // MARK: - Private
}

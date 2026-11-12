//
//  Tap.swift
//  DigitCLI
//
//  Created by JSilver on 8/16/26.
//

import ArgumentParser
import Digit
import Foundation

package struct Tap: DeviceCommand {
    // MARK: - Property
    package static let configuration = CommandConfiguration(
        commandName: Operation.tap.rawValue,
        abstract: "Tap a point."
    )
    
    @OptionGroup package var target: DeviceOption
    @Option(help: "x,y to tap") package var point: Point
    
    // MARK: - Initializer
    package init() {}
    
    // MARK: - Public
    package func perform(on device: Device) async throws -> Empty {
        try await device.run(TapOperator(at: point))
        
        return Empty()
    }
    
    // MARK: - Private
}

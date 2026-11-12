//
//  Swipe.swift
//  DigitCLI
//
//  Created by JSilver on 8/16/26.
//

import ArgumentParser
import Digit
import Foundation

package struct Swipe: DeviceCommand {
    // MARK: - Property
    package static let configuration = CommandConfiguration(
        commandName: Operation.swipe.rawValue,
        abstract: "Swipe between two points."
    )
    
    @OptionGroup package var target: DeviceOption
    @OptionGroup package var stroke: StrokeOption
    
    // MARK: - Initializer
    package init() {}
    
    // MARK: - Public
    package func perform(on device: Device) async throws -> Empty {
        try await device.run(`operator`())
        
        return Empty()
    }
    
    package func `operator`() throws -> SwipeOperator {
        try SwipeOperator(stroke.value(default: 0.3))
    }
    
    // MARK: - Private
}

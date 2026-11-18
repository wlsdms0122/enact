//
//  Drag.swift
//  DigitCLI
//
//  Created by JSilver on 8/16/26.
//

import ArgumentParser
import Digit
import Foundation

package struct Drag: DeviceCommand {
    // MARK: - Property
    package static let configuration = CommandConfiguration(
        commandName: Operation.drag.rawValue,
        abstract: "Drag between two points.",
        discussion:
            "Traced finely and held at its end before letting go, so the app reads a move that comes to rest rather than a flick."
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
    
    package func `operator`() throws -> DragOperator {
        try DragOperator(stroke.value(default: 1.0))
    }
    
    // MARK: - Private
}

//
//  LongPress.swift
//  DigitCLI
//
//  Created by JSilver on 8/16/26.
//

import ArgumentParser
import Digit
import Foundation

package struct LongPress: DeviceCommand {
    // MARK: - Property
    package static let configuration = CommandConfiguration(
        commandName: Operation.longPress.rawValue,
        abstract: "Press and hold a point."
    )
    
    @OptionGroup package var target: DeviceOption
    @Option(help: "x,y to press") package var point: Point
    @Option(help: "how long to hold") package var duration: Double = 0.5
    
    // MARK: - Initializer
    package init() {}
    
    // MARK: - Public
    package func perform(on device: Device) async throws -> Empty {
        try await device.run(`operator`())
        
        return Empty()
    }
    
    // MARK: - Private
    private func `operator`() throws -> LongPressOperator {
        try LongPressOperator(at: point, duration: duration)
    }
}

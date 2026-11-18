//
//  SetHinge.swift
//  DigitCLI
//
//  Created by JSilver on 11/5/26.
//

import ArgumentParser
import Digit
import Foundation

package struct SetHinge: DeviceCommand {
    // MARK: - Property
    package static let configuration = CommandConfiguration(
        commandName: Operation.setHinge.rawValue,
        abstract: "Fold or unfold a device that folds.",
        discussion: "Returns once the screen has followed the hinge."
    )
    
    @OptionGroup package var target: DeviceOption
    @Argument(help: "folded or unfolded") package var hinge: Hinge
    
    // MARK: - Initializer
    package init() {}
    
    // MARK: - Public
    package func perform(on device: Device) async throws -> Empty {
        try await device.run(SetHingeOperator(hinge))
        
        return Empty()
    }
    
    // MARK: - Private
}

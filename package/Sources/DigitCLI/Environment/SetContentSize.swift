//
//  SetContentSize.swift
//  DigitCLI
//
//  Created by JSilver on 8/16/26.
//

import ArgumentParser
import Digit
import Foundation

package struct SetContentSize: DeviceCommand {
    // MARK: - Property
    package static let configuration = CommandConfiguration(
        commandName: Operation.setContentSize.rawValue,
        abstract: "Set the Dynamic Type size.",
        discussion: "The accessibility-* sizes are the ones behind Larger Text."
    )
    
    @OptionGroup package var target: DeviceOption
    @Argument(help: "e.g. large, accessibility-extra-large") package var size: ContentSize
    
    // MARK: - Initializer
    package init() {}
    
    // MARK: - Public
    package func perform(on device: Device) async throws -> Empty {
        try await device.run(SetContentSizeOperator(size))
        
        return Empty()
    }
    
    // MARK: - Private
}

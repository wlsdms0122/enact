//
//  AddMedia.swift
//  DigitCLI
//
//  Created by JSilver on 8/16/26.
//

import ArgumentParser
import Digit
import Foundation

package struct AddMedia: DeviceCommand {
    // MARK: - Property
    package static let configuration = CommandConfiguration(
        commandName: Operation.addMedia.rawValue,
        abstract: "Add photos or videos to the library."
    )
    
    @OptionGroup package var target: DeviceOption
    @Argument(help: "files to add") package var paths: [String]
    
    // MARK: - Initializer
    package init() {}
    
    // MARK: - Public
    package func perform(on device: Device) async throws -> Empty {
        let media = try AddMediaOperator(paths: paths)
        
        try await device.run(media)
        
        return Empty()
    }
    
    // MARK: - Private
}

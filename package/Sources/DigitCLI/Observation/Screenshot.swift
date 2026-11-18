//
//  Screenshot.swift
//  DigitCLI
//
//  Created by JSilver on 8/16/26.
//

import ArgumentParser
import Digit
import Foundation

struct Screenshot: DeviceCommand {
    // MARK: - Property
    static let configuration = CommandConfiguration(
        commandName: Operation.screenshot.rawValue,
        abstract: "Capture the screen to a file."
    )
    
    @OptionGroup var target: DeviceOption
    @Option(help: "file to write") var output: String
    @Option(help: "png or jpeg") var format: ImageFormat = .png
    
    // MARK: - Initializer
    // MARK: - Public
    func perform(on device: Device) async throws -> Empty {
        let image = try await device.run(ScreenshotOperator(format: format))
        
        try image.write(to: URL(fileURLWithPath: output))
        
        return Empty()
    }
    
    // MARK: - Private
}

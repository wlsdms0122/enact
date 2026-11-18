//
//  DescribeScreen.swift
//  DigitCLI
//
//  Created by JSilver on 8/16/26.
//

import ArgumentParser
import Digit
import Foundation

struct DescribeScreen: DeviceCommand {
    // MARK: - Property
    static let configuration = CommandConfiguration(
        commandName: Operation.describeScreen.rawValue,
        abstract: "Print how big the screen is.",
        discussion: """
            In points: the units describe-ui reports frames in and every \
            coordinate argument takes.
            """
    )
    
    @OptionGroup var target: DeviceOption
    @OptionGroup var output: OutputOption
    
    // MARK: - Initializer
    // MARK: - Public
    func perform(on device: Device) async throws -> Screen {
        try await device.run(DescribeScreenOperator())
    }
    
    func show(_ answer: Screen) throws {
        try output.emit(answer) { "\(answer.width)x\(answer.height)" }
    }
    
    // MARK: - Private
}

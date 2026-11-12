//
//  Delete.swift
//  DigitCLI
//
//  Created by JSilver on 11/5/26.
//

import ArgumentParser
import Digit
import Foundation

struct Delete: AsyncParsableCommand {
    // MARK: - Property
    static let configuration = CommandConfiguration(
        commandName: "delete",
        abstract: "Delete the device, and everything on it.",
        discussion: "A booted device is shut down first."
    )
    
    @Option(name: .customLong("udid"), help: "udid of the device to delete") var udid: String
    
    // MARK: - Initializer
    // MARK: - Public
    func run() async throws { try DeviceSet().delete(udid: udid) }
    
    // MARK: - Private
}

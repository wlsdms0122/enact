//
//  DeviceOption.swift
//  DigitCLI
//
//  Created by JSilver on 8/16/26.
//

import ArgumentParser
import Digit
import Foundation

package struct DeviceOption: ParsableArguments {
    // MARK: - Property
    @Option(name: .customLong("udid"), help: "udid of the target device")
    package var udid: String
    
    // MARK: - Initializer
    package init() {}
    
    // MARK: - Public
    package func device() throws -> Device {
        try DeviceSet().open(udid: udid)
    }
    
    // MARK: - Private
}

//
//  AddCertificate.swift
//  DigitCLI
//
//  Created by JSilver on 11/5/26.
//

import ArgumentParser
import Digit
import Foundation

package struct AddCertificate: DeviceCommand {
    // MARK: - Property
    package static let configuration = CommandConfiguration(
        commandName: Operation.addCertificate.rawValue,
        abstract: "Add a certificate to the keychain.",
        discussion: "With --root it goes to the trusted root store, as a proxy's certificate does."
    )
    
    @OptionGroup package var target: DeviceOption
    @Argument(help: "the certificate file") package var path: String
    @Flag(help: "trust it as a root") package var root: Bool = false
    
    // MARK: - Initializer
    package init() {}
    
    // MARK: - Public
    package func perform(on device: Device) async throws -> Empty {
        try await device.run(AddCertificateOperator(path: path, root: root))
        
        return Empty()
    }
    
    // MARK: - Private
}

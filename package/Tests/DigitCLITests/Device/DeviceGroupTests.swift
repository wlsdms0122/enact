//
//  DeviceGroupTests.swift
//  DigitCLITests
//
//  Created by JSilver on 8/16/26.
//

import Digit
import Testing
@testable import DigitCLI

@Suite("The device group has a command for every operation")
struct DeviceGroupTests {
    // MARK: - Property
    // MARK: - Initializer
    // MARK: - Test
    @Test("every operation is spelled as a command", arguments: Digit.Operation.allCases)
    func everyOperationHasACommand(operation: Digit.Operation) {
        // Given
        let commands = DeviceGroup.configuration.subcommands.compactMap {
            $0.configuration.commandName
        }
        
        // When / Then
        #expect(commands.contains(operation.rawValue))
    }
}

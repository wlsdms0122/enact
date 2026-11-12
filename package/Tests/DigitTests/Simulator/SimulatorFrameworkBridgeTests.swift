//
//  SimulatorFrameworkBridgeTests.swift
//  DigitTests
//
//  Created by JSilver on 11/2/26.
//

import FBControlCore
import Foundation
import Testing
@testable import Digit

@Suite("The guest bridge arrives with the binary")
struct SimulatorFrameworkBridgeTests {
    // MARK: - Property
    // MARK: - Initializer
    // MARK: - Test
    @Test("installing writes the carried guest as an executable where idb looks for it")
    func installWritesTheGuest() throws {
        // Given
        try SimulatorFrameworkBridge.install()
        
        // When
        let directory = try #require(BundledResources.hostDirectoryPath)
        let path = URL(filePath: directory).appending(path: "SimulatorFrameworkBridge-iOS").path
        
        // Then
        #expect(FileManager.default.isExecutableFile(atPath: path))
    }
}

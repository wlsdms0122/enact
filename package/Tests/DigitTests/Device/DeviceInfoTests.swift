//
//  DeviceInfoTests.swift
//  DigitTests
//
//  Created by JSilver on 8/16/26.
//

import Foundation
import Testing
@testable import Digit

@Suite("Device information speaks Digit's vocabulary")
struct DeviceInfoTests {
    // MARK: - Property
    // MARK: - Initializer
    // MARK: - Test
    @Test("the state is encoded in Digit's own spelling")
    func stateVocabularyIsOurs() throws {
        // Given
        let sut = DeviceInfo(udid: "STUB", name: "stub", osVersion: "iOS 26.0", state: .booted)
        
        // When
        let json = try JSONSerialization.jsonObject(with: JSONEncoder().encode(sut))
        
        // Then
        #expect((json as? [String: Any])?["state"] as? String == "booted")
    }
}

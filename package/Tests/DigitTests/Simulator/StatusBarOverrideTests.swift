//
//  StatusBarOverrideTests.swift
//  DigitTests
//
//  Created by JSilver on 11/5/26.
//

import FBSimulatorControl
import Testing
@testable import Digit

@Suite("A status bar override holds each mode and state as CoreSimulator numbers it")
struct StatusBarOverrideTests {
    // MARK: - Property
    // MARK: - Initializer
    // MARK: - Test
    @Test("each mode and state set is the number CoreSimulator gives it, and what is not set is kept")
    func eachModeIsItsNumber() throws {
        // Given
        var sut = StatusBarOverride()
        sut.operatorName = "Carrier"
        let operation = try SetStatusBarOperator(
            dataNetwork: .fiveGUltraCapacity,
            wifiMode: .failed,
            cellularMode: .notSupported,
            batteryState: .charged
        )
        
        // When
        sut.apply(operation)
        
        // Then
        #expect(sut.dataNetworkType == 14)
        #expect(sut.wiFiMode == 2)
        #expect(sut.cellularMode == 0)
        #expect(sut.batteryState == 2)
        #expect(sut.operatorName == "Carrier")
    }
}

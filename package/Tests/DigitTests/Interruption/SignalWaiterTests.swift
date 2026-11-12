//
//  SignalWaiterTests.swift
//  DigitTests
//
//  Created by JSilver on 8/16/26.
//

import Foundation
import Testing
@testable import Digit

@Suite("A signal waiter takes signal handling over and gives it back")
struct SignalWaiterTests {
    // MARK: - Property
    // MARK: - Initializer
    // MARK: - Test
    @Test("arming ignores the signal and disarming restores what was there")
    func disarmingPutsTheHandlingBack() {
        // Given
        let ignoring = unsafeBitCast(SIG_IGN, to: UInt.self)
        let before = disposition(of: SIGTERM)
        
        // When
        let sut = SignalWaiter([SIGTERM])
        
        // Then
        #expect(disposition(of: SIGTERM) == ignoring, "arming has to stop the default from running")
        
        // When
        sut.disarm()
        
        // Then
        #expect(disposition(of: SIGTERM) == before, "disarming has to restore what was there before")
    }
    
    // MARK: - Private
    private func disposition(of number: Int32) -> UInt {
        let current = signal(number, SIG_IGN)
        signal(number, current)
        
        return unsafeBitCast(current, to: UInt.self)
    }
}

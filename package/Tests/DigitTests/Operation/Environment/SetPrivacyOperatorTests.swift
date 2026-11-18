//
//  SetPrivacyOperatorTests.swift
//  DigitTests
//
//  Created by JSilver on 8/16/26.
//

import Testing
@testable import Digit

@Suite("A privacy change has something to change")
struct SetPrivacyOperatorTests {
    // MARK: - Property
    // MARK: - Initializer
    // MARK: - Test
    @Test("a change with no services is refused")
    func privacyChangeNeedsSomethingToChange() {
        // When / Then
        #expect(throws: DigitError.self) {
            try SetPrivacyOperator(decision: .grant, bundleID: "com.example", services: [])
        }
    }
}

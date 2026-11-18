//
//  PushNotificationOperatorTests.swift
//  DigitTests
//
//  Created by JSilver on 8/16/26.
//

import Testing
@testable import Digit

@Suite("A push carries a payload the device will show")
struct PushNotificationOperatorTests {
    // MARK: - Property
    // MARK: - Initializer
    // MARK: - Test
    @Test(
        "a payload that is not an object with aps is refused",
        arguments: ["not json", "[1,2]", #"{"title":"hi"}"#]
    )
    func aPayloadWithoutApsIsRefused(payload: String) {
        // When / Then
        #expect(throws: DigitError.self) {
            try PushNotificationOperator(bundleID: "com.example", payload: payload)
        }
    }
    
    @Test("a payload with aps is accepted")
    func aPayloadWithApsIsAccepted() {
        // When / Then
        #expect(throws: Never.self) {
            try PushNotificationOperator(bundleID: "com.example", payload: #"{"aps":{"alert":"hi"}}"#)
        }
    }
}

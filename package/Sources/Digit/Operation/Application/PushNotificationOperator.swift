//
//  PushNotificationOperator.swift
//  Digit
//
//  Created by JSilver on 8/16/26.
//

import Foundation

public struct PushNotificationOperator: Operator {
    // MARK: - Property
    public static let operation = Operation.pushNotification
    
    public let bundleID: String
    public let payload: String
    
    // MARK: - Initializer
    public init(bundleID: String, payload: String) throws {
        guard let data = payload.data(using: .utf8),
            let object = try? JSONSerialization.jsonObject(with: data) as? [String: Any]
        else {
            throw DigitError.malformedPayload(reason: "not a JSON object")
        }
        
        guard object["aps"] != nil else {
            throw DigitError.malformedPayload(reason: "no aps key")
        }
        
        self.bundleID = bundleID
        self.payload = payload
    }
    
    // MARK: - Public
    // MARK: - Private
}

//
//  SetPrivacyOperator.swift
//  Digit
//
//  Created by JSilver on 8/16/26.
//

import Foundation

public struct SetPrivacyOperator: Operator {
    public enum Decision: String, Sendable, CaseIterable {
        case grant
        case revoke
        case reset
    }
    
    // MARK: - Property
    public static let operation = Operation.setPrivacy
    
    public let decision: Decision
    public let bundleID: String?
    public let services: Set<PrivacyService>
    
    // MARK: - Initializer
    public init(decision: Decision, bundleID: String?, services: Set<PrivacyService>) throws {
        guard !services.isEmpty else { throw DigitError.nothingToDo(field: "services") }
        
        guard decision == .reset || bundleID != nil else {
            throw DigitError.nothingToDo(field: "bundle id")
        }
        
        self.decision = decision
        self.bundleID = bundleID
        self.services = services
    }
    
    // MARK: - Public
    // MARK: - Private
}

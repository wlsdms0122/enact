//
//  RespondBiometricOperator.swift
//  Digit
//
//  Created by JSilver on 8/16/26.
//

import Foundation

public struct RespondBiometricOperator: Operator {
    // MARK: - Property
    public static let operation = Operation.respondBiometric
    
    public let outcome: BiometricOutcome
    
    // MARK: - Initializer
    public init(_ outcome: BiometricOutcome) { self.outcome = outcome }
    
    // MARK: - Public
    // MARK: - Private
}

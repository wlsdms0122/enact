//
//  ResetKeychainOperator.swift
//  Digit
//
//  Created by JSilver on 11/5/26.
//

import Foundation

// The keychain emptied of its items. A certificate added to the trusted
// root store stays trusted until the device is erased.
public struct ResetKeychainOperator: Operator {
    // MARK: - Property
    public static let operation = Operation.resetKeychain
    
    // MARK: - Initializer
    public init() {}
    
    // MARK: - Public
    // MARK: - Private
}

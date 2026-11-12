//
//  AddCertificateOperator.swift
//  Digit
//
//  Created by JSilver on 11/5/26.
//

import Foundation

// A certificate file added to the keychain, or to the trusted root store,
// where a proxy's certificate goes for the device to trust what it signs.
public struct AddCertificateOperator: Operator {
    // MARK: - Property
    public static let operation = Operation.addCertificate
    
    public let path: String
    public let root: Bool
    
    // MARK: - Initializer
    public init(path: String, root: Bool) {
        self.path = path
        self.root = root
    }
    
    // MARK: - Public
    // MARK: - Private
}

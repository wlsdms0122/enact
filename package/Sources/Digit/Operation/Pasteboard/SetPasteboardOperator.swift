//
//  SetPasteboardOperator.swift
//  Digit
//
//  Created by JSilver on 8/16/26.
//

import Foundation

public struct SetPasteboardOperator: Operator {
    // MARK: - Property
    public static let operation = Operation.setPasteboard
    
    public let text: String
    
    // MARK: - Initializer
    public init(_ text: String) { self.text = text }
    
    // MARK: - Public
    // MARK: - Private
}

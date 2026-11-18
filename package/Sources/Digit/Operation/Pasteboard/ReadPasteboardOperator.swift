//
//  ReadPasteboardOperator.swift
//  Digit
//
//  Created by JSilver on 8/16/26.
//

import Foundation

public struct ReadPasteboardOperator: Operator {
    public typealias Result = String
    
    // MARK: - Property
    public static let operation = Operation.readPasteboard
    
    // MARK: - Initializer
    public init() {}
    
    // MARK: - Public
    // MARK: - Private
}

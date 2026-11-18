//
//  TypeTextOperator.swift
//  Digit
//
//  Created by JSilver on 8/16/26.
//

import Foundation

public struct TypeTextOperator: Operator {
    // MARK: - Property
    public static let operation = Operation.typeText
    
    public let text: String
    
    // MARK: - Initializer
    public init(_ text: String) throws {
        guard !text.isEmpty else { throw DigitError.nothingToDo(field: "text") }
        
        self.text = text
    }
    
    // MARK: - Public
    // MARK: - Private
}

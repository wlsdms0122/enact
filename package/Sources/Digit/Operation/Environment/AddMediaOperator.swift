//
//  AddMediaOperator.swift
//  Digit
//
//  Created by JSilver on 8/16/26.
//

import Foundation

public struct AddMediaOperator: Operator {
    // MARK: - Property
    public static let operation = Operation.addMedia
    
    public let paths: [String]
    
    // MARK: - Initializer
    public init(paths: [String]) throws {
        guard !paths.isEmpty else { throw DigitError.nothingToDo(field: "paths") }
        
        self.paths = paths
    }
    
    // MARK: - Public
    // MARK: - Private
}

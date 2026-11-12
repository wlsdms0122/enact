//
//  RecordLogOperator.swift
//  Digit
//
//  Created by JSilver on 11/11/26.
//

import Foundation

struct RecordLogOperator: Operator {
    typealias Result = Recording
    
    // MARK: - Property
    static let operation = Operation.recordLog
    
    let path: String
    let predicate: String?
    
    // MARK: - Initializer
    // MARK: - Public
    // MARK: - Private
}

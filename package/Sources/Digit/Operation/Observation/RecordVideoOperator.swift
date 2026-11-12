//
//  RecordVideoOperator.swift
//  Digit
//
//  Created by JSilver on 8/16/26.
//

import Foundation

struct RecordVideoOperator: Operator {
    typealias Result = Recording
    
    // MARK: - Property
    static let operation = Operation.recordVideo
    
    let path: String
    
    // MARK: - Initializer
    // MARK: - Public
    // MARK: - Private
}

//
//  AppStateOperator.swift
//  Digit
//
//  Created by JSilver on 11/10/26.
//

import Foundation

public struct AppStateOperator: Operator {
    public typealias Result = AppState
    
    // MARK: - Property
    public static let operation = Operation.appState
    
    public let bundleID: String
    
    // MARK: - Initializer
    public init(bundleID: String) { self.bundleID = bundleID }
    
    // MARK: - Public
    // MARK: - Private
}

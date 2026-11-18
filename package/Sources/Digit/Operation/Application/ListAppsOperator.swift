//
//  ListAppsOperator.swift
//  Digit
//
//  Created by JSilver on 8/16/26.
//

import Foundation

public struct ListAppsOperator: Operator {
    public typealias Result = [InstalledApp]
    
    // MARK: - Property
    public static let operation = Operation.listApps
    
    // MARK: - Initializer
    public init() {}
    
    // MARK: - Public
    // MARK: - Private
}

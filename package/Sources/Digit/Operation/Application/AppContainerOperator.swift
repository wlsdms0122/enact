//
//  AppContainerOperator.swift
//  Digit
//
//  Created by JSilver on 8/16/26.
//

import Foundation

public struct AppContainerOperator: Operator {
    public typealias Result = String
    
    public enum Container: Sendable, Equatable {
        case bundle
        case data
        case group(String)
        
        var argument: String {
            switch self {
            case .bundle:
                return "app"
            
            case .data:
                return "data"
            
            case let .group(identifier):
                return identifier
            }
        }
    }
    
    // MARK: - Property
    public static let operation = Operation.appContainer
    
    public let bundleID: String
    public let container: Container
    
    // MARK: - Initializer
    public init(bundleID: String, container: Container = .bundle) {
        self.bundleID = bundleID
        self.container = container
    }
    
    // MARK: - Public
    // MARK: - Private
}

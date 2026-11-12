//
//  Operator.swift
//  Digit
//
//  Created by JSilver on 8/16/26.
//

import Foundation

public protocol Operator: Sendable {
    associatedtype Result = Void
    
    static var operation: Operation { get }
}

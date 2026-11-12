//
//  SetOrientationOperator.swift
//  Digit
//
//  Created by JSilver on 11/5/26.
//

import Foundation

public struct SetOrientationOperator: Operator {
    // MARK: - Property
    public static let operation = Operation.setOrientation
    
    public let orientation: Orientation
    
    // MARK: - Initializer
    public init(_ orientation: Orientation) { self.orientation = orientation }
    
    // MARK: - Public
    // MARK: - Private
}

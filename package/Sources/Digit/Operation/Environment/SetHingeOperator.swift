//
//  SetHingeOperator.swift
//  Digit
//
//  Created by JSilver on 11/5/26.
//

import Foundation

// Folds or unfolds a device that folds, and returns once its screen has
// followed.
public struct SetHingeOperator: Operator {
    // MARK: - Property
    public static let operation = Operation.setHinge
    
    public let hinge: Hinge
    
    // MARK: - Initializer
    public init(_ hinge: Hinge) { self.hinge = hinge }
    
    // MARK: - Public
    // MARK: - Private
}

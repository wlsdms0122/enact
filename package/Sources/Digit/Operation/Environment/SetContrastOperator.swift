//
//  SetContrastOperator.swift
//  Digit
//
//  Created by JSilver on 8/16/26.
//

import Foundation

public struct SetContrastOperator: Operator {
    // MARK: - Property
    public static let operation = Operation.setContrast
    
    public let contrast: Contrast
    
    // MARK: - Initializer
    public init(_ contrast: Contrast) { self.contrast = contrast }
    
    // MARK: - Public
    // MARK: - Private
}

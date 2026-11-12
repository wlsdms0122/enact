//
//  DragOperator.swift
//  Digit
//
//  Created by JSilver on 8/16/26.
//

import Foundation

public struct DragOperator: Operator {
    // MARK: - Property
    public static let operation = Operation.drag
    
    public let stroke: Stroke
    
    // MARK: - Initializer
    public init(_ stroke: Stroke) { self.stroke = stroke }
    
    // MARK: - Public
    // MARK: - Private
}

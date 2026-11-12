//
//  ScreenshotOperator.swift
//  Digit
//
//  Created by JSilver on 8/16/26.
//

import Foundation

public struct ScreenshotOperator: Operator {
    public typealias Result = Data
    
    // MARK: - Property
    public static let operation = Operation.screenshot
    
    public let format: ImageFormat
    
    // MARK: - Initializer
    public init(format: ImageFormat = .png) { self.format = format }
    
    // MARK: - Public
    // MARK: - Private
}

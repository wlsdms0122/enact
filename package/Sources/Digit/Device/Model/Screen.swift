//
//  Screen.swift
//  Digit
//
//  Created by JSilver on 8/16/26.
//

import Foundation

public struct Screen: Sendable, Codable, Equatable {
    // MARK: - Property
    public let width: Double
    public let height: Double
    
    // MARK: - Initializer
    public init(width: Double, height: Double) throws {
        guard width > 0 else { throw DigitError.notPositive(field: "width", value: width) }
        guard height > 0 else { throw DigitError.notPositive(field: "height", value: height) }
        
        self.width = width
        self.height = height
    }
    
    // MARK: - Public
    // MARK: - Private
}

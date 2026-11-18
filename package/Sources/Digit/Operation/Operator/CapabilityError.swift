//
//  CapabilityError.swift
//  Digit
//
//  Created by JSilver on 8/16/26.
//

import Foundation

public struct CapabilityError: Error, CustomStringConvertible {
    // MARK: - Property
    public let operation: Operation
    public let target: DeviceInfo
    
    public var description: String {
        "\(operation.rawValue): not supported on this device (\(target.udid))"
    }
    
    // MARK: - Initializer
    public init(operation: Operation, target: DeviceInfo) {
        self.operation = operation
        self.target = target
    }
    
    // MARK: - Public
    // MARK: - Private
}

//
//  OutputOption.swift
//  DigitCLI
//
//  Created by JSilver on 8/16/26.
//

import ArgumentParser
import Digit
import Foundation

public struct OutputOption: ParsableArguments {
    // MARK: - Property
    @Flag(name: .customLong("json"), help: "Emit JSON instead of the plain form.")
    public var json: Bool = false
    
    // MARK: - Initializer
    public init() {}
    
    // MARK: - Public
    public func emit<T: Encodable>(_ value: T, plain: () -> String) throws {
        if json {
            let encoder = JSONEncoder()
            encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
            
            print(String(decoding: try encoder.encode(value), as: UTF8.self))
        } else {
            let text = plain()
            
            if !text.isEmpty { print(text) }
        }
    }
    
    // MARK: - Private
}

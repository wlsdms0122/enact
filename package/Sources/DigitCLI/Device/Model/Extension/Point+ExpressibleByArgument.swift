//
//  Point+ExpressibleByArgument.swift
//  DigitCLI
//
//  Created by JSilver on 8/16/26.
//

import ArgumentParser
import Digit

extension Point: ExpressibleByArgument {
    public init?(argument: String) {
        let parts = argument.split(separator: ",", omittingEmptySubsequences: false)
        
        guard parts.count == 2, let x = Double(parts[0]), let y = Double(parts[1]) else {
            return nil
        }
        
        self.init(x: x, y: y)
    }
}

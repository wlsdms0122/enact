//
//  Element.Frame+ExpressibleByArgument.swift
//  DigitCLI
//
//  Created by JSilver on 8/16/26.
//

import ArgumentParser
import Digit

extension Element.Frame: ExpressibleByArgument {
    public init?(argument: String) {
        let parts = argument.split(separator: ",", omittingEmptySubsequences: false)
        
        guard parts.count == 4 else { return nil }
        
        let numbers = parts.compactMap { Double($0) }
        
        guard numbers.count == 4 else { return nil }
        
        self.init(x: numbers[0], y: numbers[1], width: numbers[2], height: numbers[3])
    }
}

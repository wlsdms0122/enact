//
//  SessionFailure.swift
//  DigitCLI
//
//  Created by JSilver on 11/10/26.
//

import ArgumentParser
import Digit
import Foundation

package struct SessionFailure: Error, Encodable, Sendable, Equatable {
    package enum Kind: String, Encodable, Sendable {
        case argumentRefused = "argument_refused"
        case deviceRefused = "device_refused"
    }
    
    // MARK: - Property
    package let kind: Kind
    package let detail: String
    
    // MARK: - Initializer
    package init(_ kind: Kind, _ detail: String) {
        self.kind = kind
        self.detail = detail
    }
    
    // A refusal of what the line said is the line's; any other is the device's.
    package init(performing error: any Error) {
        switch error {
        case is ValidationError:
            self.init(.argumentRefused, "\(error)")
        
        case let digit as DigitError where digit.refusesArgument:
            self.init(.argumentRefused, "\(digit)")
        
        default:
            self.init(.deviceRefused, "\(error)")
        }
    }
    
    // MARK: - Public
    // MARK: - Private
}

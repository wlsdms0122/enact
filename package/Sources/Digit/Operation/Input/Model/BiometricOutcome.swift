//
//  BiometricOutcome.swift
//  Digit
//
//  Created by JSilver on 8/16/26.
//

import Foundation

public enum BiometricOutcome: String, Sendable, CaseIterable {
    case match
    case noMatch = "no-match"
}

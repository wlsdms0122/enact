//
//  CellularMode.swift
//  Digit
//
//  Created by JSilver on 11/5/26.
//

import Foundation

// What the status bar shows of the cellular connection.
public enum CellularMode: String, Sendable, CaseIterable {
    case notSupported = "not-supported"
    case searching
    case failed
    case active
}

//
//  WifiMode.swift
//  Digit
//
//  Created by JSilver on 11/5/26.
//

import Foundation

// What the status bar shows of the Wi-Fi connection.
public enum WifiMode: String, Sendable, CaseIterable {
    case searching
    case failed
    case active
}

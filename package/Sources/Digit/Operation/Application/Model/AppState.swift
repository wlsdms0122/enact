//
//  AppState.swift
//  Digit
//
//  Created by JSilver on 11/10/26.
//

import Foundation

public enum AppState: String, Sendable, CaseIterable, Encodable {
    case notRunning = "not-running"
    case background
    // The app the screen shows.
    case foreground
}

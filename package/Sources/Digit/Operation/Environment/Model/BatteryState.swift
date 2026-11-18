//
//  BatteryState.swift
//  Digit
//
//  Created by JSilver on 11/5/26.
//

import Foundation

// How the status bar shows the battery charging.
public enum BatteryState: String, Sendable, CaseIterable {
    case discharging
    case charging
    case charged
}

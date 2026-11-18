//
//  DeviceState.swift
//  Digit
//
//  Created by JSilver on 8/16/26.
//

import Foundation

public enum DeviceState: String, Codable, Sendable {
    case creating
    case shutdown
    case booting
    case booted
    case shuttingDown = "shutting-down"
    case unknown
}

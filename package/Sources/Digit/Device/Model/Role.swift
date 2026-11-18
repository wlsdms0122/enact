//
//  Role.swift
//  Digit
//
//  Created by JSilver on 8/16/26.
//

import Foundation

public enum Role: String, Sendable, Codable, CaseIterable {
    case button
    case link
    case field
    case secureField = "secure-field"
    case toggle
    case slider
    case picker
    case key
    case text
    case heading
    case image
    case alert
    case bar
    case map
    case web
    case progress
    case container
    case unknown
}

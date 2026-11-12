//
//  InstalledApp.swift
//  Digit
//
//  Created by JSilver on 8/16/26.
//

import Foundation

public struct InstalledApp: Sendable, Encodable {
    // MARK: - Property
    public let bundleID: String
    public let name: String
    public let bundlePath: String
    public let dataContainer: String?
    public let installKind: String
    
    // MARK: - Initializer
    // MARK: - Public
    // MARK: - Private
}

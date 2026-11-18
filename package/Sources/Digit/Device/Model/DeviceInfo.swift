//
//  DeviceInfo.swift
//  Digit
//
//  Created by JSilver on 8/16/26.
//

import Foundation

public struct DeviceInfo: Codable, Sendable {
    // MARK: - Property
    public let udid: String
    public let name: String
    public let osVersion: String
    public let state: DeviceState
    
    // MARK: - Initializer
    init(udid: String, name: String, osVersion: String, state: DeviceState) {
        self.udid = udid
        self.name = name
        self.osVersion = osVersion
        self.state = state
    }
    
    // MARK: - Public
    // MARK: - Private
}

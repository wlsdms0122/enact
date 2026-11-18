//
//  ScenarioStore.swift
//  Enact
//
//  Created by JSilver on 8/16/26.
//

import Foundation

// Where scenario texts are found.
public protocol ScenarioStore: Sendable {
    // Every text this store finds, each file once.
    func sources() throws -> [ScenarioSource]
}

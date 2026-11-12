//
//  LostRecording.swift
//  EnactWarp
//
//  Created by JSilver on 11/1/26.
//

import Foundation

// A video or log the recorder could not close after its body ran, and why.
// Whatever is at its path is not one to keep.
public struct LostRecording: Sendable, Encodable, Equatable {
    // MARK: - Property
    public let path: String
    public let reason: String
    
    // MARK: - Initializer
    init(path: String, reason: String) {
        self.path = path
        self.reason = reason
    }
    
    // MARK: - Public
    // MARK: - Private
}

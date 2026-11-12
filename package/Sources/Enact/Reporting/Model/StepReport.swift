//
//  StepReport.swift
//  Enact
//
//  Created by JSilver on 8/16/26.
//

import EnactWarp
import Foundation

public struct StepReport: Sendable, Encodable {
    public enum Status: String, Sendable, Encodable {
        case running
        case ok
        case failed
    }
    
    public struct Round: Sendable, Encodable {
        // MARK: - Property
        public let index: Int
        public let steps: [StepReport]
        
        // MARK: - Initializer
        // MARK: - Public
        // MARK: - Private
    }
    
    public struct Evidence: Sendable, Encodable {
        // MARK: - Property
        public let screenshot: String?
        public let tree: String?
        
        // MARK: - Initializer
        // MARK: - Public
        // MARK: - Private
    }
    
    // MARK: - Property
    public let id: String
    public let path: String
    // The procedure the statement called, where it called one.
    public var kind: String?
    public var status: Status
    public var ms: Int
    public var returned: ReportedValue?
    public var failure: StepFailure?
    public var evidence: Evidence?
    public var steps: [StepReport]?
    public var rounds: [Round]?
    public var rescued: Bool?
    
    // MARK: - Initializer
    init(id: String, path: String, status: Status = .running, ms: Int = 0) {
        self.id = id
        self.path = path
        self.status = status
        self.ms = ms
    }
    
    // MARK: - Public
    // MARK: - Private
}

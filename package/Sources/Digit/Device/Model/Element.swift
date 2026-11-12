//
//  Element.swift
//  Digit
//
//  Created by JSilver on 8/16/26.
//

import Foundation

public struct Element: Sendable, Codable {
    public struct Frame: Sendable, Codable, Equatable {
        // MARK: - Property
        public let x: Double
        public let y: Double
        public let width: Double
        public let height: Double
        
        public var center: Point { Point(x: x + width / 2, y: y + height / 2) }
        
        // MARK: - Initializer
        public init(x: Double, y: Double, width: Double, height: Double) {
            self.x = x
            self.y = y
            self.width = width
            self.height = height
        }
        
        // MARK: - Public
        // MARK: - Private
    }
    
    // MARK: - Property
    public let id: String?
    public let label: String?
    public let value: String?
    public let role: Role
    public let frame: Frame
    public let enabled: Bool
    public let actions: [String]
    public let children: [Element]
    
    // MARK: - Initializer
    public init(
        id: String? = nil,
        label: String? = nil,
        value: String? = nil,
        role: Role = .unknown,
        frame: Frame,
        enabled: Bool = true,
        actions: [String] = [],
        children: [Element] = []
    ) {
        self.id = id
        self.label = label
        self.value = value
        self.role = role
        self.frame = frame
        self.enabled = enabled
        self.actions = actions
        self.children = children
    }
    
    // MARK: - Public
    // MARK: - Private
}

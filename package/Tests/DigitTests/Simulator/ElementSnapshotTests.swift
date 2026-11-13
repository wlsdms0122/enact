//
//  ElementSnapshotTests.swift
//  DigitTests
//
//  Created by JSilver on 11/13/26.
//

import Foundation
import Testing
@testable import Digit

@Suite("An element of the test daemon's snapshot is read as describe-ui reads one")
struct ElementSnapshotTests {
    // The properties of the daemon's snapshot the reading takes.
    private final class Node: NSObject {
        // MARK: - Property
        @objc let elementType: NSNumber
        @objc let traits: NSNumber
        @objc let frame: NSValue
        @objc let identifier: String?
        @objc let label: String?
        @objc let value: Any?
        @objc let enabled: Bool
        @objc let children: [Node]
        
        // MARK: - Initializer
        init(type: Int, traits: UInt64 = 0, label: String? = nil, identifier: String? = nil, value: Any? = nil, children: [Node] = []) {
            self.elementType = NSNumber(value: type)
            self.traits = NSNumber(value: traits)
            self.frame = NSValue(rect: NSRect(x: 1, y: 2, width: 3, height: 4))
            self.identifier = identifier
            self.label = label
            self.value = value
            self.enabled = true
            self.children = children
        }
    }
    
    // MARK: - Property
    // MARK: - Initializer
    // MARK: - Test
    @Test("its role comes from its type where its traits name none, and an empty label or identifier is none")
    func itIsReadAsDescribeUIReadsOne() {
        // Given
        let cell = Node(type: 75, label: "", identifier: "", children: [Node(type: 9, label: "General", identifier: "settings.general")])
        
        // When
        let sut = Element(snapshot: cell)
        
        // Then
        #expect(sut.role == .container)
        #expect(sut.label == nil)
        #expect(sut.id == nil)
        #expect(sut.frame == Element.Frame(x: 1, y: 2, width: 3, height: 4))
        #expect(sut.children.map(\.role) == [.button])
        #expect(sut.children.map(\.label) == ["General"])
    }
    
    @Test("a value the snapshot holds as a number is its text")
    func aNumberValueIsText() {
        // Given
        let toggle = Node(type: 40, label: "Wi-Fi", value: NSNumber(value: 1))
        
        // When
        let sut = Element(snapshot: toggle)
        
        // Then
        #expect(sut.role == .toggle)
        #expect(sut.value == "1")
    }
}

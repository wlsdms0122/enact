//
//  ScreenObserverTests.swift
//  EnactTests
//
//  Created by JSilver on 11/10/26.
//

import Foundation
import Testing
@testable import Digit
@testable import Enact
@testable import EnactWarp

@Suite("An observer reads the screen through the library's own look, element_at and displayed_text")
struct ScreenObserverTests {
    // MARK: - Property
    // A screen whose heading shows its text in its value, with a field and a
    // button inside a list.
    private let elements = [
        Element(value: "General", role: .heading, frame: Element.Frame(x: 16, y: 100, width: 133, height: 40)),
        Element(
            id: "list",
            role: .container,
            frame: Element.Frame(x: 0, y: 200, width: 400, height: 400),
            children: [
                Element(value: "Search", role: .field, frame: Element.Frame(x: 16, y: 210, width: 368, height: 36)),
                Element(label: "About", role: .button, frame: Element.Frame(x: 16, y: 260, width: 368, height: 52))
            ]
        )
    ]
    
    // MARK: - Initializer
    // MARK: - Test
    @Test("a look reads every element in reading order with the text it shows")
    func aLookReadsWhatEachElementShows() async throws {
        // Given
        let stage = try DeviceStage(elements: elements)
        let sut = try await ScreenObserver(device: stage.environment.device)
        
        // When
        let seen = try await sut.look()
        
        // Then
        #expect(seen.screen == (try Screen(width: 400, height: 800)))
        #expect(seen.elements.map(\.text) == ["General", "", "Search", "About"])
        #expect(seen.elements.map(\.snapshot.indexPath) == [[0], [1], [1, 0], [1, 1]])
    }
    
    @Test("what a press at a point lands on stands in no look")
    func anElementAtAPointStandsInNoLook() async throws {
        // Given
        let stage = try DeviceStage(elements: elements)
        let sut = try await ScreenObserver(device: stage.environment.device)
        
        // When
        let hit = try await sut.element(at: Point(x: 80, y: 120), on: try Screen(width: 400, height: 800))
        
        // Then
        #expect(hit?.text == "General")
        #expect(hit?.snapshot.indexPath == [])
    }
    
    // MARK: - Private
}

//
//  LookTests.swift
//  EnactWarpTests
//
//  Created by JSilver on 10/31/26.
//

import Foundation
import Testing
import Warp
@testable import Digit
@testable import EnactWarp

@Suite("A look reads the screen once, and questions are asked of what it read")
struct LookTests {
    // MARK: - Property
    // A sheet holding a caption and a button, and a slider below it, on a
    // screen of 400 by 800.
    private let elements = [
        Element(
            label: "Sheet",
            role: .container,
            frame: Element.Frame(x: 0, y: 0, width: 400, height: 400),
            children: [
                Element(label: "Caption", role: .text, frame: Element.Frame(x: 10, y: 10, width: 100, height: 20)),
                Element(label: "Save", role: .button, frame: Element.Frame(x: 10, y: 300, width: 80, height: 40))
            ]
        ),
        Element(label: "Volume", value: "50%", role: .slider, frame: Element.Frame(x: 0, y: 600, width: 400, height: 40))
    ]
    
    // MARK: - Initializer
    // MARK: - Test
    @Test("every element comes in reading order, each before the elements inside it, with where it sits in the tree")
    func aLookReadsEveryElement() async throws {
        // Given
        let sut = try DeviceStage(elements: elements)
        
        // When
        let result = try await sut.run(verbCall("look", returns: "Enact.Screen"))
        
        // Then
        guard case let .struct(screen) = result else {
            Issue.record("\(result) is not a screen")
            
            return
        }
        
        let seen = try [Snapshot](try #require(screen["elements"]))
        
        #expect(screen["width"] == .double(400))
        #expect(screen["height"] == .double(800))
        #expect(seen.map(\.label) == ["Sheet", "Caption", "Save", "Volume"])
        #expect(seen.map(\.indexPath) == [[0], [0, 0], [0, 1], [1]])
        #expect(seen.map(\.role) == [.container, .text, .button, .slider])
    }
    
    @Test("a question over the look is a filter, and its answer a snapshot a verb takes")
    func aQuestionIsAFilter() async throws {
        // Given
        let sut = try DeviceStage(elements: elements)
        let text = scenarioFile("""
        failing: anything
        body:
          - let: seen
            value: { call: { procedure: look } }
          - let: saves
            value: { of: { ref: seen.elements }, filter: { closure: { parameters: [ one: Enact.Snapshot ], result: { of: { ref: one.label }, is: Save } } } }
          - value: { call: { procedure: tap, arguments: { on: { ref: "saves[0]" } } } }
        """)
        
        // When
        _ = try await sut.run(text)
        
        // Then
        #expect(sut.backend.performed.map(String.init(describing:)) == ["TapOperator(point: Digit.Point(x: 50.0, y: 320.0))"])
    }
    
    @Test("within keeps what sits inside a container at any depth", arguments: [
        ("seen.elements[0]", ["Caption", "Save"]),
        ("seen.elements[1]", []),
        ("seen.elements[2]", [])
    ])
    func withinKeepsWhatIsInside(_ container: String, _ expected: [String]) async throws {
        // When
        let seen = try await asked("{ call: { procedure: within, arguments: { elements: { ref: seen.elements }, in: { ref: \"\(container)\" } } } }")
        
        // Then
        #expect(seen.map(\.label) == expected)
    }
    
    @Test("within a snapshot standing in no look, as element_at reads one, keeps nothing")
    func withinNoLookKeepsNothing() async throws {
        // When
        let seen = try await asked(
            "{ call: { procedure: within, arguments: { elements: { ref: seen.elements }, in: \(snapshotLiteral(role: "container", indexPath: [])) } } }"
        )
        
        // Then
        #expect(seen.isEmpty)
    }
    
    @Test("in_area keeps what meets an area of the screen")
    func inAreaKeepsWhatMeetsTheArea() async throws {
        // When
        let seen = try await asked(
            "{ call: { procedure: in_area, arguments: { elements: { ref: seen.elements }, "
                + "area: { struct: { x: 0, y: 0, width: 1, height: 0.5 } }, screen: { ref: seen } } } }"
        )
        
        // Then
        #expect(seen.map(\.label) == ["Sheet", "Caption", "Save"])
    }
    
    @Test("nearest orders by how far the middle of each is from a point")
    func nearestOrdersByDistance() async throws {
        // When
        let seen = try await asked(
            "{ call: { procedure: nearest, arguments: { elements: { ref: seen.elements }, "
                + "to: { struct: { x: 0.5, y: 1 } }, screen: { ref: seen } } } }"
        )
        
        // Then
        #expect(seen.map(\.label) == ["Volume", "Save", "Sheet", "Caption"])
    }
    
    @Test("an area or a point outside the screen's fractions is refused", arguments: [
        "{ call: { procedure: in_area, arguments: { elements: { ref: seen.elements }, area: { struct: { x: 0, y: 0, width: 400, height: 400 } }, screen: { ref: seen } } } }",
        "{ call: { procedure: in_area, arguments: { elements: { ref: seen.elements }, area: { struct: { x: 0, y: 0, width: 0, height: 1 } }, screen: { ref: seen } } } }",
        "{ call: { procedure: nearest, arguments: { elements: { ref: seen.elements }, to: { struct: { x: 2, y: 0 } }, screen: { ref: seen } } } }"
    ])
    func outsideTheFractionsIsRefused(_ question: String) async throws {
        // When
        let refusal = await #expect(throws: StepFailure.self) {
            _ = try await asked(question)
        }
        
        // Then
        #expect(try #require(refusal).kind == .argumentRefused)
    }
    
    @Test("element_at reads the element a press at a point of the screen lands on, standing in no look")
    func elementAtReadsTheHitElement() async throws {
        // Given
        let sut = try DeviceStage(elements: elements)
        
        // When
        let result = try await sut.run(
            verbCall("element_at", "{ at: { struct: { x: 0.05, y: 0.39 } } }", returns: "Enact.Snapshot?")
        )
        
        // Then
        let hit = try Snapshot(result)
        
        #expect(hit.label == "Save")
        #expect(hit.indexPath.isEmpty)
    }
    
    @Test("element_at where nothing answers is none")
    func elementAtNothingIsNone() async throws {
        // Given
        let sut = try DeviceStage(elements: elements)
        
        // When
        let result = try await sut.run(
            verbCall("element_at", "{ at: { struct: { x: 0.5, y: 0.95 } } }", returns: "Enact.Snapshot?")
        )
        
        // Then
        #expect(result == .null)
    }
    
    // MARK: - Private
    // Looks once and answers with what the question asked of it.
    private func asked(_ question: String) async throws -> [Snapshot] {
        let sut = try DeviceStage(elements: elements)
        let text = scenarioFile("""
        returns: "Array<Enact.Snapshot>"
        failing: anything
        body:
          - let: seen
            value: { call: { procedure: look } }
        result: \(question)
        """)
        
        return try [Snapshot](try await sut.run(text))
    }
}

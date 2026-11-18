//
//  ScreenObserver.swift
//  Enact
//
//  Created by JSilver on 11/10/26.
//

import Digit
import EnactWarp
import Foundation
import Warp
import WarpSyntax

// Reads a device's screen through the library's own `look`, `element_at` and
// `displayed_text`, so what it sees is what a scenario run on the device sees.
package struct ScreenObserver: Sendable {
    // MARK: - Property
    private static let module = "Observation"
    private static let text = """
        name: \(module)
        uses: [Enact]
        procedures:
          seen:
            access: public
            returns: Enact.Screen
            failing: anything
            result: { call: { procedure: look } }
          hit:
            access: public
            parameters: [ at: Enact.Point ]
            returns: "Enact.Snapshot?"
            failing: anything
            result: { call: { procedure: element_at, arguments: { at: { ref: at } } } }
          shown:
            access: public
            parameters: [ elements: "Array<Enact.Snapshot>" ]
            returns: "Array<String>"
            result: { of: { ref: elements }, map: { closure: { parameters: [ one: Enact.Snapshot ], returns: String, result: { call: { procedure: displayed_text, arguments: { of: { ref: one } } } } } } }
        """
    
    private let image: Image
    private let executor: Executor
    
    // MARK: - Initializer
    package init(device: Device) async throws {
        let vocabulary = try EnactVocabulary()
        let document = try vocabulary.frontend().document(from: Self.text).document
        let module = try Loader().load(try BinaryEncoding().value(from: document))
        
        self.image = try await ScenarioBuilder(vocabulary: vocabulary).image(of: [module])
        self.executor = Executor(
            environment: EnactEnvironment(
                device: device,
                outputDirectory: OutputDirectory(url: FileManager.default.temporaryDirectory)
            )
        )
    }
    
    // MARK: - Public
    package func look() async throws -> ObservedScreen {
        let seen = try await run("seen")
        
        guard case let .struct(held) = seen, let elements = held["elements"] else {
            throw RunRefused("a look returned \(seen), which is no screen")
        }
        
        return ObservedScreen(try Screen(seen), elements: try await observed(try [Snapshot](elements)))
    }
    
    // The element a press at a point of the screen lands on, or nil where
    // nothing answers.
    package func element(at point: Point, on screen: Screen) async throws -> ObservedElement? {
        let at = screen.fraction(of: point)
        let fraction: Warp.Value = try .holding(
            [(name: "x", value: .double(at.x)), (name: "y", value: .double(at.y))],
            named: "Enact.Point"
        )
        let hit = try await run("hit", ["at": fraction])
        
        guard hit != .null else { return nil }
        
        return try await observed([try Snapshot(hit)]).first
    }
    
    // MARK: - Private
    private func observed(_ snapshots: [Snapshot]) async throws -> [ObservedElement] {
        let shown = try await run("shown", ["elements": .array(try snapshots.map(Warp.Value.init))])
        
        guard case let .array(texts) = shown, texts.count == snapshots.count else {
            throw RunRefused("displayed_text read \(shown) of \(snapshots.count) elements")
        }
        
        return try zip(snapshots, texts).map { snapshot, text in
            guard case let .string(text) = text else { throw RunRefused("displayed_text read \(text)") }
            
            return ObservedElement(snapshot, text: text)
        }
    }
    
    private func run(_ procedure: String, _ arguments: [Warp.Name: Warp.Value] = [:]) async throws -> Warp.Value {
        try await executor.run(image, entry: try Warp.Name("\(Self.module).\(procedure)"), arguments: arguments)
    }
}

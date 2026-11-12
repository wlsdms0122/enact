//
//  EngineTests.swift
//  EnactTests
//
//  Created by JSilver on 10/31/26.
//

import Foundation
import Testing
import Warp
@testable import Digit
@testable import Enact
@testable import EnactWarp

@Suite("An engine reads a scenario and every one it calls, and builds them")
struct EngineTests {
    // MARK: - Property
    private let directory: URL
    private let sut: Engine
    
    // MARK: - Initializer
    init() throws {
        directory = URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true)
            .appendingPathComponent("enact-scenarios-\(UUID().uuidString)", isDirectory: true)
        sut = try Engine()
        
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        try write("login", """
        name: Login
        uses: [Enact]
        procedures:
          main:
            access: public
            parameters:
              - user: String
            failing: anything
            body:
              - let: name
                value: { call: { procedure: type_text, arguments: { text: { ref: user } } } }
        """)
        try write("checkout", """
        name: Checkout
        uses: [Enact, Login]
        procedures:
          main:
            access: public
            parameters:
              - amount: Int
              - note: { type: String?, hint: "what the transfer says" }
              - way: Enact.Direction?
            failing: anything
            body:
              - let: signIn
                value: { call: { procedure: Login.main, arguments: { user: me } } }
              - let: shot
                value: { call: { procedure: screenshot } }
        """)
        try write("broken", "procedures: [")
    }
    
    // MARK: - Test
    @Test("a scenario is built with every scenario it calls, and the graph says who calls whom and what each asks of a device")
    func aScenarioIsBuiltWithWhatItCalls() async throws {
        defer { cleanUp() }
        
        // When
        let scenario = try await sut.check("Checkout", store: SearchPathStore(roots: [directory]))
        
        // Then
        #expect(scenario.scenarios == ["Checkout", "Login"])
        #expect(scenario.graph == [
            Scenario.Calls(scenario: "Checkout", calls: ["Login"], verbs: ["screenshot", "type_text"]),
            Scenario.Calls(scenario: "Login", calls: [], verbs: ["type_text"])
        ])
    }
    
    @Test("an input is read as the type its parameter declares, and an optional one may be left out")
    func anInputIsReadAsItsType() async throws {
        defer { cleanUp() }
        
        // Given
        let scenario = try await sut.check("Checkout", store: SearchPathStore(roots: [directory]))
        
        // When
        let arguments = try #require(scenario.entry).arguments(from: ["amount": "1000"])
        
        // Then
        #expect(arguments == ["amount": .int(1000), "note": .null, "way": .null])
    }
    
    @Test("an input naming a case is that case of the enum its parameter declares")
    func anInputNamesACase() async throws {
        defer { cleanUp() }
        
        // Given
        let scenario = try await sut.check("Checkout", store: SearchPathStore(roots: [directory]))
        
        // When
        let arguments = try #require(scenario.entry).arguments(from: ["amount": "1", "way": "up"])
        
        // Then
        #expect(arguments["way"] == (try Warp.Value.holding([], named: "Enact.Direction.up")))
    }
    
    @Test("a run with an optional input left out goes to its end")
    func aRunWithAnOptionalLeftOutCompletes() async throws {
        defer { cleanUp() }
        
        // Given
        let scenario = try await sut.check("Checkout", store: SearchPathStore(roots: [directory]))
        let entry = try #require(scenario.entry)
        let stage = try DeviceStage()
        let vocabulary = try EnactVocabulary.shipped.get()
        
        // When
        let report = await ScenarioRunner(vocabulary: vocabulary).run(
            scenario.image,
            entry: entry.name,
            arguments: try entry.arguments(from: ["amount": "1000"]),
            scenario: scenario.name,
            statements: entry.statements,
            device: stage.environment.device,
            lock: DeviceLock(directory: stage.directory.appendingPathComponent("run-lock")),
            outputDirectory: stage.environment.outputDirectory
        )
        
        // Then
        #expect(report.outcome == .completed, "\(report.detail ?? "")")
        #expect(entry.statements.contains(StatementAddress(["signIn", "name"])))
    }
    
    @Test("an input the entry does not take, one it needs and lacks, and one that does not spell its type are refused", arguments: [
        ["amount": "1", "amout": "2"],
        [:],
        ["amount": "a lot"],
        ["amount": "1", "way": "north"]
    ])
    func aWrongInputIsRefused(_ inputs: [String: String]) async throws {
        defer { cleanUp() }
        
        // Given
        let entry = try #require(try await sut.check("Checkout", store: SearchPathStore(roots: [directory])).entry)
        
        // When / Then
        #expect(throws: InputRefused.self) { try entry.arguments(from: inputs) }
    }
    
    @Test("a scenario with no public main builds, with no entry")
    func aScenarioWithoutMainBuilds() async throws {
        defer { cleanUp() }
        
        // Given
        try write("helper", """
        name: Helper
        uses: [Enact]
        procedures:
          tidy:
            access: public
            body: [ { let: x, value: 1 } ]
        """)
        
        // When
        let scenario = try await sut.check("Helper", store: SearchPathStore(roots: [directory]))
        
        // Then
        #expect(scenario.entry == nil)
    }
    
    @Test("a scenario with no public main is type-checked")
    func aScenarioWithoutMainIsTypeChecked() async throws {
        defer { cleanUp() }
        
        // Given
        try write("helper", """
        name: Helper
        uses: [Enact]
        procedures:
          tidy:
            access: public
            body: [ { let: x, type: Int, value: "one" } ]
        """)
        
        // When / Then
        await #expect(throws: ScenarioRefused.self) {
            _ = try await sut.check("Helper", store: SearchPathStore(roots: [directory]))
        }
    }
    
    @Test("a run of a scenario with no public main is refused")
    func aRunWithoutMainIsRefused() async throws {
        defer { cleanUp() }
        
        // Given
        try write("helper", """
        name: Helper
        uses: [Enact]
        procedures:
          tidy:
            access: public
            body: [ { let: x, value: 1 } ]
        """)
        
        // When
        let report = await sut.run(
            "Helper",
            store: SearchPathStore(roots: [directory]),
            udid: "none",
            outputDirectory: directory.appendingPathComponent("out")
        )
        
        // Then
        #expect(report.refused == .loadFailed)
        #expect(report.detail?.contains("no public procedure called main") == true)
    }
    
    @Test("a call reaches the scenario that declares the name, whatever its file is called")
    func aCallReachesTheDeclaredName() async throws {
        defer { cleanUp() }
        
        // Given
        try write("sign-in-flow", """
        name: SignIn
        uses: [Enact]
        procedures:
          main:
            access: public
            body: [ { let: x, value: 1 } ]
        """)
        try write("caller", """
        name: Caller
        uses: [Enact, SignIn]
        procedures:
          main:
            access: public
            body: [ { let: signIn, value: { call: { procedure: SignIn.main } } } ]
        """)
        
        // When
        let scenario = try await sut.check("Caller", store: SearchPathStore(roots: [directory]))
        
        // Then
        #expect(scenario.scenarios == ["Caller", "SignIn"])
        #expect(scenario.graph.first { calls in calls.scenario == "Caller" }?.calls == ["SignIn"])
    }
    
    @Test("a scenario in a folder at any depth is found under the name it declares, and a hidden folder is passed over")
    func aScenarioInAFolderIsFound() async throws {
        defer { cleanUp() }
        
        // Given
        try write("flows/pay/transfer", """
        name: Transfer
        uses: [Enact, Login]
        procedures:
          main:
            access: public
            failing: anything
            body: [ { let: signIn, value: { call: { procedure: Login.main, arguments: { user: me } } } } ]
        """)
        try write(".draft/login", "name: Login\nprocedures: { main: 3 }")
        
        // When
        let scenario = try await sut.check("Transfer", store: SearchPathStore(roots: [directory]))
        
        // Then
        #expect(scenario.scenarios == ["Login", "Transfer"])
    }
    
    @Test("a scenario is not found under its file's name")
    func aFileNameIsNoName() async throws {
        defer { cleanUp() }
        
        // When
        let refusal = await #expect(throws: ScenarioLookupError.self) {
            _ = try await sut.check("checkout", store: SearchPathStore(roots: [directory]))
        }
        
        // Then
        #expect("\(try #require(refusal))" == "no scenario declares the name 'checkout'")
    }
    
    @Test("a root that is no directory is refused, not passed over")
    func aMissingRootIsRefused() async throws {
        defer { cleanUp() }
        
        // Given
        let missing = directory.appendingPathComponent("nowhere")
        
        // When
        let refusal = await #expect(throws: ScenarioLookupError.self) {
            _ = try await sut.check("Checkout", store: SearchPathStore(roots: [directory, missing]))
        }
        
        // Then
        #expect("\(try #require(refusal))" == "no directory to find scenarios in at \(missing.path)")
    }
    
    @Test("a file reached from two roots, or pinned and found as well, is one scenario")
    func aFileReachedTwiceIsOne() async throws {
        defer { cleanUp() }
        
        // Given
        try write("flows/pay", """
        name: Pay
        uses: [Enact, Login]
        procedures:
          main:
            access: public
            failing: anything
            body: [ { let: signIn, value: { call: { procedure: Login.main, arguments: { user: me } } } } ]
        """)
        let roots = [directory, directory.appendingPathComponent("flows")]
        let pinned = PinnedStore(
            file: file("checkout"),
            text: try String(contentsOfFile: file("checkout"), encoding: .utf8),
            rest: SearchPathStore(roots: roots)
        )
        
        // When
        let searched = try await sut.check("Pay", store: SearchPathStore(roots: roots))
        let run = try await sut.check(pinned.name, store: pinned)
        
        // Then
        #expect(searched.scenarios == ["Login", "Pay"])
        #expect(run.scenarios == ["Checkout", "Login"])
    }
    
    @Test("a pinned text that declares no name is found under its file's name")
    func aPinnedTextWithoutANameIsItsFile() async throws {
        defer { cleanUp() }
        
        // Given
        let pinned = PinnedStore(
            file: "walk.yaml",
            text: "uses: [Enact]\nprocedures:\n  main:\n    access: public\n    body: [ { let: x, value: 1 } ]",
            rest: SearchPathStore(roots: [directory])
        )
        
        // When
        let scenario = try await sut.check(pinned.name, store: pinned)
        
        // Then
        #expect(pinned.name == "walk")
        #expect(scenario.entry != nil)
    }
    
    @Test("a scenario declaring a module of the vocabulary is no module a call reaches", arguments: ["Enact", "Standard"])
    func aVocabularyNameIsNoScenario(_ name: String) async throws {
        defer { cleanUp() }
        
        // Given
        try write("impostor", "name: \(name)\nprocedures: { main: 3 }")
        
        // When
        let scenario = try await sut.check("Checkout", store: SearchPathStore(roots: [directory]))
        
        // Then
        #expect(scenario.scenarios == ["Checkout", "Login"])
    }
    
    @Test("a name two scenarios declare is refused where a scenario uses it, and nowhere else")
    func aNameDeclaredTwiceIsRefusedWhereCalled() async throws {
        defer { cleanUp() }
        
        // Given
        for file in ["twin-a", "twin-b"] {
            try write(file, """
            name: Twin
            uses: [Enact]
            procedures:
              main:
                access: public
                body: [ { let: x, value: 1 } ]
            """)
        }
        try write("caller", """
        name: Caller
        uses: [Enact, Twin]
        procedures:
          main:
            access: public
            body: [ { let: twin, value: { call: { procedure: Twin.main } } } ]
        """)
        
        // When
        let refusal = await #expect(throws: ScenarioLookupError.self) {
            _ = try await sut.check("Caller", store: SearchPathStore(roots: [directory]))
        }
        
        // Then
        #expect("\(try #require(refusal))".hasSuffix("\(file("twin-a")), \(file("twin-b"))"))
        _ = try await sut.check("Checkout", store: SearchPathStore(roots: [directory]))
    }
    
    @Test("a build refusal names the file it stands in, at the line and column of its text")
    func aBuildRefusalIsPlacedInTheText() async throws {
        defer { cleanUp() }
        
        // Given
        try write("typo", """
        name: Typo
        uses: [Enact]
        procedures:
          main:
            access: public
            failing: anything
            body:
              - let: typed
                value: { call: { procedure: type_text, arguments: { text: 3 } } }
        """)
        try write("caller", """
        name: Caller
        uses: [Enact, Typo]
        procedures:
          main:
            access: public
            body: [ { let: typo, value: { call: { procedure: Typo.main } } } ]
        """)
        
        // When
        let refusal = await #expect(throws: ScenarioRefused.self) {
            _ = try await sut.check("Caller", store: SearchPathStore(roots: [directory]))
        }
        
        // Then
        #expect("\(try #require(refusal))" == "\(file("typo")):9:61: sending 'Enact.type_text' with text, which holds Int where String is declared")
    }
    
    @Test("a text the front end refuses is named with the line and column of the refusal")
    func aFrontEndRefusalNamesTheScenario() async throws {
        defer { cleanUp() }
        
        // Given
        try write("unknown", """
        name: Unknown
        uses: [Enact]
        procedures:
          main:
            access: public
            body: [ { let: x, value: { call: { procedure: fly } } } ]
        """)
        
        // When
        let refusal = await #expect(throws: ScenarioRefused.self) {
            _ = try await sut.check("Unknown", store: SearchPathStore(roots: [directory]))
        }
        
        // Then
        #expect("\(try #require(refusal))".hasPrefix("\(file("unknown")):6:"))
    }
    
    @Test("a run refused before the device says why, and is written when asked")
    func aRefusedRunIsReported() async throws {
        defer { cleanUp() }
        
        // When
        let report = await sut.run(
            "Checkout",
            store: SearchPathStore(roots: [directory]),
            udid: "booted",
            inputs: ["amout": "1"],
            outputDirectory: directory.appendingPathComponent("out"),
            record: true
        )
        
        // Then
        #expect(report.refused == .inputsRejected)
        #expect(report.reportPath.map { path in FileManager.default.fileExists(atPath: path) } == true)
    }
    
    // MARK: - Private
    private func write(_ name: String, _ text: String) throws {
        let file = directory.appendingPathComponent("\(name).yaml")
        
        try FileManager.default.createDirectory(at: file.deletingLastPathComponent(), withIntermediateDirectories: true)
        try text.write(to: file, atomically: true, encoding: .utf8)
    }
    
    private func file(_ name: String) -> String {
        directory.appendingPathComponent("\(name).yaml").path
    }
    
    private func cleanUp() {
        try? FileManager.default.removeItem(at: directory)
    }
}

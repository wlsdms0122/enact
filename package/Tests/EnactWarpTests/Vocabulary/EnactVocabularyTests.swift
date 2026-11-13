//
//  EnactVocabularyTests.swift
//  EnactWarpTests
//
//  Created by JSilver on 10/31/26.
//

import Foundation
import Testing
import Warp
import WarpSyntax
@testable import Digit
@testable import EnactWarp

@Suite("Enact's library over the native verbs")
struct EnactVocabularyTests {
    // MARK: - Property
    // MARK: - Initializer
    // MARK: - Test
    @Test("what ships is what lib/ holds", arguments: [
        ("Enact.yaml", Library.text),
        ("Enact.interface.warpt", Library.types),
        ("Native.interface.warpt", Library.natives)
    ])
    func whatShipsIsWhatTheRepositoryHolds(_ name: String, _ sut: String) throws {
        // Given
        let file = URL(fileURLWithPath: #filePath).resolvingSymlinksInPath()
            .deletingLastPathComponent()   // Vocabulary
            .deletingLastPathComponent()   // EnactTests
            .deletingLastPathComponent()   // Tests
            .deletingLastPathComponent()   // package
            .deletingLastPathComponent()   // the repository
            .appendingPathComponent("lib")
            .appendingPathComponent(name)
        
        // When
        let written = try String(contentsOf: file, encoding: .utf8)
        
        // Then
        #expect(
            sut == written.trimmingCharacters(in: .newlines),
            "lib/\(name) differs from what ships. Run tool/embed-library.sh"
        )
    }
    
    @Test("every native the interface declares is carried out by the Swift of its name, and no Swift stands undeclared")
    func everyDeclaredNativeIsCarriedOut() throws {
        // Given
        let declared = try Loader().interface(try TextEncoding().value(from: Library.natives))
        
        // When
        let sut = try EnactVocabulary.implementations()
        
        // Then
        #expect(Set(sut.keys) == Set(declared.procedures.keys))
    }
    
    @Test("each set of words is the enum the interface declares", arguments: [
        (EnactVocabulary.role.name, EnactVocabulary.role.declaration),
        (EnactVocabulary.direction.name, EnactVocabulary.direction.declaration),
        (EnactVocabulary.button.name, EnactVocabulary.button.declaration),
        (EnactVocabulary.modifier.name, EnactVocabulary.modifier.declaration),
        (EnactVocabulary.biometricOutcome.name, EnactVocabulary.biometricOutcome.declaration),
        (EnactVocabulary.appearance.name, EnactVocabulary.appearance.declaration),
        (EnactVocabulary.contentSize.name, EnactVocabulary.contentSize.declaration),
        (EnactVocabulary.contrast.name, EnactVocabulary.contrast.declaration),
        (EnactVocabulary.orientation.name, EnactVocabulary.orientation.declaration),
        (EnactVocabulary.privacyDecision.name, EnactVocabulary.privacyDecision.declaration),
        (EnactVocabulary.privacyService.name, EnactVocabulary.privacyService.declaration),
        (EnactVocabulary.dataNetwork.name, EnactVocabulary.dataNetwork.declaration),
        (EnactVocabulary.wifiMode.name, EnactVocabulary.wifiMode.declaration),
        (EnactVocabulary.cellularMode.name, EnactVocabulary.cellularMode.declaration),
        (EnactVocabulary.batteryState.name, EnactVocabulary.batteryState.declaration)
    ])
    func eachWordSetIsTheDeclaredEnum(_ name: Warp.Name, _ sut: TypeDeclaration) throws {
        // Given
        let declared = try Loader().interface(try TextEncoding().value(from: Library.types))
        
        // When / Then
        #expect(declared.types[name] == sut, "\(name)")
    }
    
    @Test("each verb of the library is one call of the native of its name, handing its parameters in order, every native has one, and a composition calls none")
    func everyVerbCallsItsNative() throws {
        // Given
        let document = try EnactVocabulary.shipped.get().library
        let library = try Loader().load(document)
        let natives = Set(try EnactVocabulary.natives().procedures.keys.map(\.spelling))
        var verbs: Set<Warp.Name> = []
        
        for (name, sut) in library.procedures {
            // When
            let sent = statements(of: name, in: document).compactMap { statement -> (selector: String, arguments: [Warp.Value])? in
                guard let call = call(in: field("value", of: statement)), natives.contains(call.selector) else { return nil }
                
                return call
            }
            let handed = sent.first?.arguments.map { argument -> Warp.Name? in
                guard case let .string(path)? = field("ref", of: argument) else { return nil }
                
                return Warp.Name(stringLiteral: path)
            }
            
            // Then
            guard !sent.isEmpty else {
                // A composition says it with the verbs, and no native carries its name.
                #expect(!natives.contains(native(of: name)), "\(name)")
                
                continue
            }
            
            verbs.insert(name)
            
            #expect(sent.map(\.selector) == [native(of: name)])
            #expect(handed == sut.signature.parameters.map(\.name), "\(name)")
        }
        
        #expect(Set(verbs.map(native(of:))) == natives)
    }
    
    @Test("the library builds with the natives and the standard vocabulary")
    func theLibraryBuilds() async throws {
        // Given
        let sut = try EnactVocabulary.shipped.get().linkables
        
        // When / Then
        _ = try await Builder().build(sut)
    }
    
    @Test("running at once is not in what a scenario links")
    func runningAtOnceIsNotLinked() throws {
        // Given
        let sut = try EnactVocabulary.shipped.get().linkables
        
        // When
        let declared = sut.flatMap { module in module.procedures.keys.map(\.spelling) }
        
        // Then
        #expect(declared.contains("Standard.Text.characters"))
        #expect(!declared.contains { name in name.hasPrefix("Standard.Concurrent.") })
    }
    
    @Test("a run asks the device for what every verb it can reach asks, through the procedures it calls")
    func aRunAsksWhatItCanReach() async throws {
        // Given
        let sut = try await image(of: """
        uses: [Enact]
        procedures:
          main:
            access: public
            failing: anything
            body:
              - value: { call: { procedure: tap, arguments: { on: \(snapshotLiteral()) } } }
              - value: { call: { procedure: away } }
          away:
            failing: anything
            result: { call: { procedure: swipe, arguments: { direction: { case: up } } } }
          unreached:
            returns: String
            failing: anything
            result: { call: { procedure: screenshot } }
        """)
        
        // When
        let asked = try EnactVocabulary.operations(reachedFrom: entry, in: sut)
        
        // Then
        #expect(asked == [.tap: ["tap"], .describeScreen: ["swipe", "tap"], .describeUI: ["tap"], .swipe: ["swipe"]])
    }
    
    @Test("a run that drives no device asks it for nothing")
    func aRunWithoutDeviceVerbsAsksNothing() async throws {
        // Given
        let sut = try await image(of: verbCall("sleep", "{ sec: 0, because: nothing }"))
        
        // When / Then
        #expect(try EnactVocabulary.operations(reachedFrom: entry, in: sut).isEmpty)
    }
    
    // MARK: - Private
    private func native(of verb: Warp.Name) -> String {
        verb.spelling.replacingOccurrences(of: "Enact.", with: "Enact.Native.")
    }
    
    private func field(_ key: Warp.Name, of value: Warp.Value?) -> Warp.Value? {
        guard case let .dictionary(fields)? = value else { return nil }
        
        return fields[key]
    }
    
    // The statements of a procedure's body, as its document writes them.
    private func statements(of procedure: Warp.Name, in document: Warp.Value) -> [Warp.Value] {
        let declared = field(Warp.Name(stringLiteral: procedure.spelling), of: field("procedures", of: document))
        
        guard case let .array(statements)? = field("body", of: declared) else { return [] }
        
        return statements
    }
    
    // The call a statement's value makes, itself or as what it returns.
    private func call(in value: Warp.Value?) -> (selector: String, arguments: [Warp.Value])? {
        let call = field("call", of: value) ?? field("call", of: field("return", of: value))
        
        guard case let .string(selector)? = field("procedure", of: call) else { return nil }
        guard case let .array(arguments)? = field("arguments", of: call) else { return (selector, []) }
        
        return (selector, arguments)
    }
}

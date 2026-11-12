//
//  AppContainerReaderTests.swift
//  DigitTests
//
//  Created by JSilver on 8/16/26.
//

import Testing
@testable import Digit

@Suite("An app container answer reads as a path or a set of groups")
struct AppContainerReaderTests {
    // MARK: - Property
    private let sut = AppContainerReader()
    
    // MARK: - Initializer
    // MARK: - Test
    @Test("no path is a missing container", arguments: ["(null)", "", "  \n"])
    func missingContainerIsNotAPath(output: String) throws {
        // When
        let refusal = #expect(throws: DigitError.self) { _ = try readPath(output) }
        
        // Then
        guard case .noSuchContainer = try #require(refusal) else {
            Issue.record("\(output) should read as a missing container, not as unreadable")
            
            return
        }
    }
    
    @Test(
        "a group listing is not a path",
        arguments: ["group.one\t/tmp/one\ngroup.two\t/tmp/two", "group.one\t/tmp/one"]
    )
    func aListingIsNotAPath(output: String) throws {
        // When
        let refusal = #expect(throws: DigitError.self) { _ = try readPath(output) }
        
        // Then
        guard case .unreadableOutput = try #require(refusal) else {
            Issue.record("a listing should read as unreadable, not as a missing container")
            
            return
        }
    }
    
    @Test("groups are read as name and path pairs")
    func appGroupsAreReadAsPairs() throws {
        // When / Then
        #expect(
            try readGroups("group.one\t/tmp/one\ngroup.two\t/tmp/two\n")
                == ["group.one": "/tmp/one", "group.two": "/tmp/two"]
        )
        #expect(
            try readGroups("  group.one\t/tmp/one\n   group.two\t/tmp/two")
                == ["group.one": "/tmp/one", "group.two": "/tmp/two"]
        )
    }
    
    @Test("an app in no groups is an empty answer", arguments: ["", "  \n", "\n\n"])
    func noGroupsIsEmpty(output: String) throws {
        // When / Then
        #expect(try readGroups(output).isEmpty)
    }
    
    @Test(
        "a listing that is not pairs, or names a group twice, is refused",
        arguments: ["group.one /tmp/one", "group.one\t/a\ngroup.one\t/b"]
    )
    func unreadableGroupListingIsRefused(output: String) throws {
        // When
        let refusal = #expect(throws: DigitError.self) { _ = try readGroups(output) }
        
        // Then
        let error = try #require(refusal)
        
        #expect(error.description.contains("UDID"))
        
        guard case .unreadableOutput = error else {
            Issue.record("\(output) should read as unreadable")
            
            return
        }
    }
    
    // MARK: - Private
    private func readPath(_ output: String) throws -> String {
        try sut.path(
            in: sut.lines(of: output),
            asked: sut.arguments("UDID", "com.example", "data"),
            bundleID: "com.example",
            container: "data"
        )
    }
    
    private func readGroups(_ output: String) throws -> [String: String] {
        try sut.groups(in: sut.lines(of: output), asked: sut.arguments("UDID", "com.example", "data"))
    }
}

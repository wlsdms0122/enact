//
//  EnumCaseTests.swift
//  EnactWarpTests
//
//  Created by JSilver on 11/4/26.
//

import Foundation
import Testing
import Warp
@testable import EnactWarp

@Suite("A case of an enum is a struct under its spelling")
struct EnumCaseTests {
    // MARK: - Property
    // MARK: - Initializer
    // MARK: - Test
    @Test("a case is read back from its value, the enum's name before the last dot and the case's after it")
    func aCaseIsReadFromItsValue() throws {
        // Given
        let sut = EnumCase("remote", of: "App.Target")
        
        // When
        let read = EnumCase(try sut.value(carrying: [(name: "port", value: .int(8080))]), among: ["App.Target"])
        
        // Then
        #expect(read == sut)
    }
    
    @Test("a struct of no enum given, and a value that is no struct, is no case")
    func anotherValueIsNoCase() throws {
        // Given
        let sut: Set<Warp.Name> = ["App.Target"]
        
        // When
        let point = try Warp.Value.holding([(name: "x", value: .int(1))], named: "App.Point")
        let other = try EnumCase("up", of: "App.Way").value()
        
        // Then
        #expect(EnumCase(point, among: sut) == nil)
        #expect(EnumCase(other, among: sut) == nil)
        #expect(EnumCase(.string("App.Target.local"), among: sut) == nil)
    }
}

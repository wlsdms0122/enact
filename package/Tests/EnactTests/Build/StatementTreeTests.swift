//
//  StatementTreeTests.swift
//  EnactTests
//
//  Created by JSilver on 11/1/26.
//

import Foundation
import Testing
import Warp
@testable import Enact

@Suite("A statement tree has every address the journal can record")
struct StatementTreeTests {
    // MARK: - Property
    // MARK: - Initializer
    // MARK: - Test
    @Test("a closure a verb runs, a branch, a try and a procedure called stand under the statement that holds them")
    func everyHeldBodyStandsUnderItsStatement() throws {
        // Given
        let scenario = try document(of: """
        uses: [Enact]
        procedures:
          main:
            access: public
            failing: anything
            body:
              - let: settled
                value:
                  call:
                    procedure: repeat
                    arguments:
                      timeout: 1
                      body: { closure: { returns: Int, body: [ { let: shown, value: 1 } ], result: { ref: shown } } }
                      until: { closure: { parameters: [ n: Int ], result: true } }
              - value:
                  cases:
                    - when: false
                      then:
                        - let: hidden
                          value: 1
              - let: tried
                value:
                  try:
                    body:
                      - let: inside
                        value: 1
                    catch:
                      - let: caught
                        value: 2
              - let: login
                value: { call: { procedure: signIn } }
          signIn:
            body:
              - let: name
                value: 1
        """)
        
        // When
        let sut = StatementTree(procedures: scenario.procedures, entry: entry).addresses.map(\.description)
        
        // Then
        #expect(Set(sut).isSuperset(of: [
            "settled", "settled/shown", "[1]", "[1]/hidden", "tried", "tried/inside", "tried/caught", "login", "login/name"
        ]))
        #expect(!sut.contains("hidden"))
        #expect(!sut.contains("name"))
    }
    
    @Test("a statement writing into a path is called by the path's head, as the run calls it")
    func aWriteIsCalledByItsHead() throws {
        // Given
        let scenario = try document(of: """
        uses: [Enact]
        procedures:
          main:
            access: public
            body:
              - var: tally
                type: Dictionary<String, Int>
                value: { dictionary: [] }
              - set: 'tally["a"]'
                value: 1
        """)
        
        // When
        let sut = StatementTree(procedures: scenario.procedures, entry: entry).addresses.map(\.description)
        
        // Then
        #expect(Set(sut) == ["tally"])
    }
    
    @Test("the statements of a procedure called inside itself stand under every call of it")
    func aRecursiveCallHoldsItsProcedure() throws {
        // Given
        let scenario = try document(of: """
        uses: [Enact]
        procedures:
          main:
            access: public
            body:
              - let: first
                value: { call: { procedure: walk } }
          walk:
            body:
              - let: step
                value: 1
              - let: again
                value: { call: { procedure: walk } }
        """)
        
        // When
        let sut = StatementTree(procedures: scenario.procedures, entry: entry)
        
        // Then
        #expect(sut.contains(StatementAddress(["first", "again", "again", "step"])))
        #expect(!sut.contains(StatementAddress(["first", "again", "again", "first"])))
        #expect(!sut.contains(StatementAddress(["step"])))
    }
    
    @Test("a procedure its result calls again holds no more than it stands under, so an address off the tree is refused")
    func aRecursiveResultEnds() throws {
        // Given
        let scenario = try document(of: """
        uses: [Enact]
        procedures:
          main:
            access: public
            body:
              - let: first
                value: { call: { procedure: walk } }
          walk:
            body:
              - let: step
                value: 1
            result: { call: { procedure: bounce } }
          bounce:
            result: { call: { procedure: walk } }
        """)
        
        // When
        let sut = StatementTree(procedures: scenario.procedures, entry: entry)
        
        // Then
        #expect(sut.contains(StatementAddress(["first", "step"])))
        #expect(!sut.contains(StatementAddress(["first", "stepp"])))
    }
    
    @Test("a statement calling two procedures inside themselves holds the statements of both")
    func twoRecursiveCallsAtOneStatement() throws {
        // Given
        let scenario = try document(of: """
        uses: [Enact]
        procedures:
          main:
            access: public
            body:
              - let: first
                value: { call: { procedure: one } }
          one:
            body:
              - let: inner
                value: { call: { procedure: two } }
          two:
            body:
              - let: both
                value: { call: { procedure: one, arguments: [ { call: { procedure: two } } ] } }
        """)
        
        // When
        let sut = StatementTree(procedures: scenario.procedures, entry: entry)
        
        // Then
        #expect(sut.contains(StatementAddress(["first", "inner", "both", "inner"])))
        #expect(sut.contains(StatementAddress(["first", "inner", "both", "both"])))
    }
    
    @Test("a call inside itself under another one's arguments leaves the outer call's statements reachable")
    func aRecursiveCallInsideAnotherOnesArguments() throws {
        // Given
        let scenario = try document(of: """
        uses: [Enact]
        procedures:
          main:
            access: public
            body:
              - let: first
                value: { call: { procedure: walk } }
          walk:
            body:
              - let: s
                value:
                  try:
                    body:
                      - let: x
                        value: 1
                    catch:
                      - let: caught
                        value: 2
              - let: a
                value:
                  call:
                    procedure: walk
                    arguments: [ { closure: { body: [ { let: s, value: { call: { procedure: walk } } } ] } } ]
        """)
        
        // When
        let sut = StatementTree(procedures: scenario.procedures, entry: entry)
        
        // Then
        #expect(sut.contains(StatementAddress(["first", "a", "s", "x"])))
    }
    
    // MARK: - Private
}

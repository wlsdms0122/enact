//
//  PasteboardActionTests.swift
//  EnactWarpTests
//
//  Created by JSilver on 10/31/26.
//

import Foundation
import Testing
import Warp
@testable import EnactWarp

@Suite("set_pasteboard puts text on the pasteboard, and read_pasteboard reads it")
struct PasteboardActionTests {
    // MARK: - Property
    // MARK: - Initializer
    // MARK: - Test
    @Test("the text goes to the device as written")
    func theTextGoesAsWritten() async throws {
        // Given
        let sut = try DeviceStage()
        
        // When
        _ = try await sut.run(verbCall("set_pasteboard", "{ text: \"copied, as is\" }"))
        
        // Then
        #expect(sut.backend.performed.map(String.init(describing:)) == ["SetPasteboardOperator(text: \"copied, as is\")"])
    }
    
    @Test("what is on the pasteboard is read as text")
    func thePasteboardIsReadAsText() async throws {
        // Given
        let sut = try DeviceStage()
        
        // When
        let result = try await sut.run(verbCall("read_pasteboard", returns: "String"))
        
        // Then
        #expect(result == .string("on the pasteboard"))
        #expect(sut.backend.performed.map(String.init(describing:)) == ["ReadPasteboardOperator()"])
    }
    
    // MARK: - Private
}

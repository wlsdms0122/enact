//
//  RoleTests.swift
//  DigitTests
//
//  Created by JSilver on 8/16/26.
//

import Testing
@testable import Digit

@Suite("A simulator node's traits and type read as a role")
struct RoleTests {
    // MARK: - Property
    // MARK: - Initializer
    // MARK: - Test
    @Test("traits decide before the type does", arguments: [
        (["Scrollable", "Button"], "Button", Role.button),
        (["Header", "Scrollable"], "Heading", Role.heading),
        (["Scrollable", "Adjustable"], "Slider", Role.slider),
        (["TextEntry", "SecureTextField"], "TextField", Role.secureField),
        (["Scrollable"], "Group", Role.container),
        ([], "WebView", Role.web)
    ])
    func rolesComeFromTraitsBeforeTypes(traits: [String], type: String, role: Role) {
        // When / Then
        #expect(Role(traits: traits, type: type) == role)
    }
    
    @Test("an unnamed shape reads as unknown")
    func unnamedShapesReadAsUnknown() {
        // When / Then
        #expect(Role(traits: ["Scrollable"], type: "SomethingAppleAddsIn2027") == .unknown)
        #expect(Role(traits: [], type: nil) == .unknown)
    }
    
    @Test("shapes seen on real screens are named")
    func measuredShapesAreNamed() {
        // When / Then
        #expect(Role(traits: ["Scrollable"], type: "ScrollArea") == .container)
        #expect(Role(traits: ["Scrollable"], type: "GenericElement") == .text)
    }
}

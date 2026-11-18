//
//  AccessibilityDocumentElementTests.swift
//  DigitTests
//
//  Created by JSilver on 11/2/26.
//

import FBSimulatorAX
import Testing
@testable import Digit

@Suite("An application element that answers nothing reads as silent")
struct AccessibilityDocumentElementTests {
    // MARK: - Property
    // MARK: - Initializer
    // MARK: - Test
    @Test("a bare application element with no frame is silent")
    func bareApplicationIsSilent() {
        // Given
        let sut = element(type: "Application", width: 0, height: 0)
        
        // When
        let silent = sut.isSilentApplication
        
        // Then
        #expect(silent)
    }
    
    @Test("an application element that reports its frame is not silent")
    func framedApplicationIsNotSilent() {
        // Given
        let sut = element(type: "Application", width: 402, height: 874)
        
        // When
        let silent = sut.isSilentApplication
        
        // Then
        #expect(!silent)
    }
    
    @Test("an application element with children is not silent")
    func applicationWithChildrenIsNotSilent() {
        // Given
        let sut = element(
            type: "Application",
            width: 0,
            height: 0,
            children: [element(type: "Button", width: 44, height: 44)]
        )
        
        // When
        let silent = sut.isSilentApplication
        
        // Then
        #expect(!silent)
    }
    
    @Test("a frameless element that is not an application is not silent")
    func framelessButtonIsNotSilent() {
        // Given
        let sut = element(type: "Button", width: 0, height: 0)
        
        // When
        let silent = sut.isSilentApplication
        
        // Then
        #expect(!silent)
    }
    
    // MARK: - Private
    private func element(
        type: String,
        width: Double,
        height: Double,
        children: [AccessibilityDocumentElement] = []
    ) -> AccessibilityDocumentElement {
        var element = AccessibilityDocumentElement(children: children)
        element.type = type
        element.frame = AccessibilityFrame(x: 0, y: 0, width: width, height: height)
        
        return element
    }
}

//
//  KeyboardGraphTests.swift
//  DigitTests
//
//  Created by JSilver on 11/10/26.
//

import Testing
@testable import Digit

@Suite("The keyboard graph finds the way to a key over the layers seen")
struct KeyboardGraphTests {
    // MARK: - Property
    private let letters = KeyboardState(keys: [.character("a"), .shift, .more, .nextKeyboard], nextKeyboard: "한국어")
    private let capitals = KeyboardState(keys: [.character("A"), .shift, .more, .nextKeyboard], nextKeyboard: "한국어")
    private let numbers = KeyboardState(keys: [.character("1"), .shift, .more, .nextKeyboard], nextKeyboard: "한국어")
    private let hangul = KeyboardState(keys: [.character("ㄱ"), .shift, .more, .nextKeyboard], nextKeyboard: "English (US)")
    
    // MARK: - Initializer
    // MARK: - Test
    @Test("a layer seen through taps is reached along them, fewest first")
    func aSeenLayerIsReachedAlongItsTaps() {
        // Given
        var sut = KeyboardGraph()
        sut.record(.shift, from: letters, to: capitals)
        sut.record(.more, from: letters, to: numbers)
        sut.record(.more, from: capitals, to: numbers)
        sut.record(.nextKeyboard, from: numbers, to: hangul)
        
        // When
        let step = sut.step(from: capitals, toward: { state in state.keys.contains(.character("ㄱ")) })
        
        // Then
        #expect(step == .more)
    }
    
    @Test("a key on no layer seen is looked for behind the nearest control not tapped yet")
    func anUnseenKeyIsLookedForBehindAnUntappedControl() {
        // Given
        var sut = KeyboardGraph()
        sut.record(.shift, from: letters, to: capitals)
        sut.record(.shift, from: capitals, to: letters)
        
        // When
        let step = sut.step(from: capitals, toward: { state in state.keys.contains(.character("1")) })
        
        // Then
        #expect(step == .more)
    }
    
    @Test("once every control seen has been tapped, a key on none of the layers has no way")
    func anExhaustedGraphHasNoWay() {
        // Given
        var sut = KeyboardGraph()
        let single = KeyboardState(keys: [.character("a"), .shift], nextKeyboard: nil)
        let shifted = KeyboardState(keys: [.character("A"), .shift], nextKeyboard: nil)
        sut.record(.shift, from: single, to: shifted)
        sut.record(.shift, from: shifted, to: single)
        
        // When
        let step = sut.step(from: single, toward: { state in state.keys.contains(.character("é")) })
        
        // Then
        #expect(step == nil)
        #expect(!sut.contains(.character("é")))
    }
    
    @Test("a route with fewer Next keyboard taps is taken over one with fewer taps")
    func aRouteAvoidsSwitchingKeyboards() {
        // Given
        var sut = KeyboardGraph()
        let hangulNumbers = KeyboardState(keys: [.character("1"), .shift, .more, .nextKeyboard], nextKeyboard: "English (US)")
        sut.record(.nextKeyboard, from: letters, to: hangulNumbers)
        sut.record(.shift, from: letters, to: capitals)
        sut.record(.more, from: capitals, to: numbers)
        
        // When
        let step = sut.step(from: letters, toward: { state in state.keys.contains(.character("1")) })
        
        // Then
        #expect(step == .shift)
    }
    
    @Test("a key on no layer seen is looked for behind the control preferred on a layer first")
    func aPreferredControlIsTriedFirst() {
        // Given
        var sut = KeyboardGraph()
        sut.visit(letters)
        
        // When
        let step = sut.step(
            from: letters,
            toward: { state in state.keys.contains(.character("ㄱ")) },
            preferring: { _ in .nextKeyboard }
        )
        
        // Then
        #expect(step == .nextKeyboard)
    }
    
    @Test("a preferred control already tapped leaves the others to be tried")
    func aTappedPreferredControlFallsBackToTheOthers() {
        // Given
        var sut = KeyboardGraph()
        sut.record(.nextKeyboard, from: letters, to: letters)
        
        // When
        let step = sut.step(
            from: letters,
            toward: { state in state.keys.contains(.character("ㄱ")) },
            preferring: { _ in .nextKeyboard }
        )
        
        // Then
        #expect(step == .shift)
    }
    
    @Test("the keyboards having a key are told by what their Next keyboard names")
    func keyboardsHavingAKeyAreToldByNextKeyboard() {
        // Given
        var sut = KeyboardGraph()
        sut.visit(letters)
        sut.visit(hangul)
        
        // When
        let keyboards = sut.keyboards(having: .character("ㄱ"))
        
        // Then
        #expect(keyboards == ["English (US)"])
    }
    
    @Test("the keyboards are the ones Next keyboard named, in the order seen")
    func keyboardsAreNamedByNextKeyboard() {
        // Given
        var sut = KeyboardGraph()
        
        // When
        sut.visit(hangul)
        sut.record(.nextKeyboard, from: hangul, to: letters)
        sut.record(.shift, from: letters, to: capitals)
        
        // Then
        #expect(sut.keyboards == ["English (US)", "한국어"])
    }
}

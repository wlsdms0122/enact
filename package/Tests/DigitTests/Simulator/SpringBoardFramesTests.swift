//
//  SpringBoardFramesTests.swift
//  DigitTests
//
//  Created by JSilver on 11/5/26.
//

import CoreGraphics
import FBSimulatorAX
import FBSimulatorControl
import Testing
@testable import Digit

@Suite("SpringBoard's frames on a turned display are turned into the screen's")
struct SpringBoardFramesTests {
    // MARK: - Property
    private static let springBoard: Int64 = 70079
    
    // MARK: - Initializer
    // MARK: - Test
    @Test("on an opened iPhone Duo, turned clockwise, a home screen icon stands where the screen shows it")
    func aClockwiseFrameIsTurned() {
        // Given
        let sut = SpringBoardFrames(process: Self.springBoard, rotation: .clockwise, upright: CGSize(width: 669, height: 951))
        
        // When
        let frame = sut.frame(Element.Frame(x: 248, y: 331, width: 86, height: 64), of: element(pid: Self.springBoard))
        
        // Then
        #expect(frame == Element.Frame(x: 556, y: 248, width: 64, height: 86))
    }
    
    @Test("a display turned upside down or counterclockwise turns the frame the same way", arguments: [
        (SimulatorDisplayRotation.upsideDown, Element.Frame(x: 60, y: 140, width: 30, height: 40)),
        (SimulatorDisplayRotation.counterclockwise, Element.Frame(x: 20, y: 60, width: 40, height: 30)),
        (SimulatorDisplayRotation.upright, Element.Frame(x: 10, y: 20, width: 30, height: 40))
    ])
    func eachTurnIsTurned(_ rotation: SimulatorDisplayRotation, _ expected: Element.Frame) {
        // Given
        let sut = SpringBoardFrames(process: Self.springBoard, rotation: rotation, upright: CGSize(width: 100, height: 200))
        
        // When
        let frame = sut.frame(Element.Frame(x: 10, y: 20, width: 30, height: 40), of: element(pid: Self.springBoard))
        
        // Then
        #expect(frame == expected)
    }
    
    @Test("an app's frame is already the screen's")
    func anAppFrameStays() {
        // Given
        let sut = SpringBoardFrames(process: Self.springBoard, rotation: .clockwise, upright: CGSize(width: 669, height: 951))
        let read = Element.Frame(x: 340, y: 303, width: 527, height: 52)
        
        // When
        let frame = sut.frame(read, of: element(pid: 427))
        
        // Then
        #expect(frame == read)
    }
    
    // MARK: - Private
    private func element(pid: Int64) -> AccessibilityDocumentElement {
        var element = AccessibilityDocumentElement(children: [])
        element.pid = pid
        
        return element
    }
}

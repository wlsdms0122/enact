//
//  SpringBoardFrames.swift
//  Digit
//
//  Created by JSilver on 11/5/26.
//

import CoreGraphics
import FBSimulatorAX
import FBSimulatorControl
import Foundation

// SpringBoard writes its accessibility frames in its display's upright space,
// where an app writes its own in the screen's, the space a tap lands in. On a
// turned display, as an opened foldable's is, SpringBoard's frames are turned
// into the screen's.
struct SpringBoardFrames {
    // MARK: - Property
    private let process: Int64
    private let rotation: SimulatorDisplayRotation
    private let upright: CGSize
    
    // MARK: - Initializer
    init(process: Int64, rotation: SimulatorDisplayRotation, upright: CGSize) {
        self.process = process
        self.rotation = rotation
        self.upright = upright
    }
    
    // MARK: - Public
    // Where an element read at a frame stands on the screen.
    func frame(_ frame: Element.Frame, of element: AccessibilityDocumentElement) -> Element.Frame {
        guard (element.pid ?? nil) == process else { return frame }
        
        let width = Double(upright.width)
        let height = Double(upright.height)
        
        switch rotation {
        case .upright:
            return frame
        
        case .clockwise:
            return Element.Frame(
                x: height - frame.y - frame.height,
                y: frame.x,
                width: frame.height,
                height: frame.width
            )
        
        case .upsideDown:
            return Element.Frame(
                x: width - frame.x - frame.width,
                y: height - frame.y - frame.height,
                width: frame.width,
                height: frame.height
            )
        
        case .counterclockwise:
            return Element.Frame(
                x: frame.y,
                y: width - frame.x - frame.width,
                width: frame.height,
                height: frame.width
            )
        
        @unknown default:
            return frame
        }
    }
    
    // MARK: - Private
}

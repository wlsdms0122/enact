//
//  SimulatorHIDEvent+Stroke.swift
//  Digit
//
//  Created by JSilver on 8/16/26.
//

import Foundation
import FBSimulatorControl

extension SimulatorHIDEvent {
    static func swipe(_ stroke: Stroke, delta: Double) -> SimulatorHIDEvent {
        .swipe(
            stroke.start.x,
            yStart: stroke.start.y,
            xEnd: stroke.end.x,
            yEnd: stroke.end.y,
            delta: delta,
            duration: stroke.duration
        )
    }
    
    // The stroke traced a delta apart, then held at its end before the finger
    // lifts. A scroll view flings at the speed of the last move it read, and a
    // touch reported where it already is reads as no move, so the held finger
    // is reported half a point across the stroke and back, at the rate a screen
    // samples touches. It lifts at rest, and the content goes as far as the
    // stroke and no further.
    static func drag(_ stroke: Stroke, delta: Double, hold: TimeInterval) -> SimulatorHIDEvent {
        let (width, height) = (stroke.end.x - stroke.start.x, stroke.end.y - stroke.start.y)
        let length = hypot(width, height)
        let steps = max(Int((length / delta).rounded(.up)), 1)
        let moves = (1...steps).flatMap { step in
            let progress = Double(step) / Double(steps)
            
            return [
                SimulatorHIDEvent.delay(stroke.duration / Double(steps)),
                .touch(direction: .down, x: stroke.start.x + width * progress, y: stroke.start.y + height * progress)
            ]
        }
        let samples = max(Int((hold * 60).rounded(.up)), 1)
        let across = (x: -height / length * 0.5, y: width / length * 0.5)
        let rest = (0..<samples).flatMap { sample in
            let side = (samples - sample) % 2 == 0 ? 1.0 : 0
            
            return [
                SimulatorHIDEvent.delay(hold / Double(samples)),
                .touch(direction: .down, x: stroke.end.x + across.x * side, y: stroke.end.y + across.y * side)
            ]
        }
        
        return .composite(
            [.touch(direction: .down, x: stroke.start.x, y: stroke.start.y)]
                + moves
                + rest
                + [.touch(direction: .up, x: stroke.end.x, y: stroke.end.y)]
        )
    }
}

//
//  SimulatorHIDEvent+Stroke.swift
//  Digit
//
//  Created by JSilver on 8/16/26.
//

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
}

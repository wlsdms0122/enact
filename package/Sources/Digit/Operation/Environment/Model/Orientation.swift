//
//  Orientation.swift
//  Digit
//
//  Created by JSilver on 11/5/26.
//

import Foundation

// Which way the device is held, as the interface turns to follow it.
public enum Orientation: String, Sendable, CaseIterable {
    case portrait
    case portraitUpsideDown = "portrait-upside-down"
    case landscapeLeft = "landscape-left"
    case landscapeRight = "landscape-right"
}

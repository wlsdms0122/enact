//
//  VideoFormat.swift
//  Digit
//
//  Created by JSilver on 11/10/26.
//

import Foundation

public enum VideoFormat: String, Sendable, CaseIterable {
    // H.264 as an Annex B elementary stream.
    case h264
    // H.264 in fragmented MP4.
    case fmp4
}

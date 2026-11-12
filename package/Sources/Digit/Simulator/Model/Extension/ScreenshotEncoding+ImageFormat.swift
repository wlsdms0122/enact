//
//  ScreenshotEncoding+ImageFormat.swift
//  Digit
//
//  Created by JSilver on 8/16/26.
//

import FBControlCore

extension ScreenshotEncoding {
    init(_ imageFormat: ImageFormat) {
        switch imageFormat {
        case .png:
            self = .png
        
        case .jpeg:
            self = .jpeg(quality: Self.defaultJPEGQuality)
        }
    }
}

//
//  VideoStreamFormat+VideoFormat.swift
//  Digit
//
//  Created by JSilver on 11/10/26.
//

import FBVideoCore

extension VideoStreamFormat {
    init(_ videoFormat: VideoFormat) {
        switch videoFormat {
        case .h264:
            self = .compressedVideo(withCodec: .h264, transport: .annexB)
        
        case .fmp4:
            self = .compressedVideo(withCodec: .h264, transport: .fmp4)
        }
    }
}

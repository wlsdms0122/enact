//
//  StreamVideoOperator.swift
//  Digit
//
//  Created by JSilver on 11/10/26.
//

import Foundation

public struct StreamVideoOperator: Operator {
    public typealias Result = VideoStream
    
    // MARK: - Property
    public static let operation = Operation.streamVideo
    
    public let format: VideoFormat
    // Nil sends a frame only when the screen changes, so a still screen sends none.
    public let framesPerSecond: Int?
    public let sink: @Sendable (Data) -> Void
    
    // MARK: - Initializer
    public init(
        format: VideoFormat = .h264,
        framesPerSecond: Int? = nil,
        sink: @escaping @Sendable (Data) -> Void
    ) throws {
        if let framesPerSecond, framesPerSecond <= 0 {
            throw DigitError.notPositive(field: "frames per second", value: Double(framesPerSecond))
        }
        
        self.format = format
        self.framesPerSecond = framesPerSecond
        self.sink = sink
    }
    
    // MARK: - Public
    // MARK: - Private
}

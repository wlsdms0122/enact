//
//  StrokeOption.swift
//  DigitCLI
//
//  Created by JSilver on 8/16/26.
//

import ArgumentParser
import Digit
import Foundation

package struct StrokeOption: ParsableArguments {
    // MARK: - Property
    @Option(help: "x,y the gesture starts at") package var from: Point
    @Option(help: "x,y the gesture ends at") package var to: Point
    @Option(help: "how long the gesture takes") package var duration: Double?
    
    // MARK: - Initializer
    package init() {}
    
    // MARK: - Public
    package func value(default fallback: Double) throws -> Stroke {
        try Stroke(start: from, end: to, duration: duration ?? fallback)
    }
    
    // MARK: - Private
}

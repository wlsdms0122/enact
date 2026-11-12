//
//  MoveSlider.swift
//  DigitCLI
//
//  Created by JSilver on 8/16/26.
//

import ArgumentParser
import Digit
import Foundation

package struct MoveSlider: DeviceCommand {
    // MARK: - Property
    package static let configuration = CommandConfiguration(
        commandName: Operation.moveSlider.rawValue,
        abstract: "Move a slider from where it is to where it should be.",
        discussion: """
            The frame comes from describe-ui as-is, and --from is where the \
            slider stands now, because a drag only takes hold if it starts on the knob, \
            so that is given rather than guessed. Both positions are 0…1 along \
            the track, which on a stepped slider is not the same as that \
            fraction of its range.
            """
    )
    
    @OptionGroup package var target: DeviceOption
    @Option(help: "the slider's frame as x,y,width,height") package var frame: Element.Frame
    @Option(help: "where it stands now, 0…1") package var from: Double
    @Option(help: "where to leave it, 0…1") package var to: Double
    @Option(help: "how long the drag takes") package var duration: Double = 0.4
    
    // MARK: - Initializer
    package init() {}
    
    // MARK: - Public
    package func perform(on device: Device) async throws -> Empty {
        try await device.run(`operator`())
        
        return Empty()
    }
    
    // MARK: - Private
    private func `operator`() throws -> MoveSliderOperator {
        try MoveSliderOperator(
            frame: frame,
            from: from,
            to: to,
            duration: duration
        )
    }
}

//
//  EnactEnvironment.swift
//  EnactWarp
//
//  Created by JSilver on 10/31/26.
//

import Digit
import Foundation
import Warp

// What a run lends its device verbs: the one device it drives, where its
// artifacts land and the recordings it landed.
package struct EnactEnvironment: Warp.Environment {
    // MARK: - Property
    package let device: Device
    package let outputDirectory: OutputDirectory
    package let recordings: RecordingLog
    
    // MARK: - Initializer
    package init(device: Device, outputDirectory: OutputDirectory, recordings: RecordingLog = RecordingLog()) {
        self.device = device
        self.outputDirectory = outputDirectory
        self.recordings = recordings
    }
    
    // MARK: - Public
    static func from<P: NativeProcedure>(_ invocation: Invocation<P>) throws -> EnactEnvironment {
        guard let environment = invocation.environment as? EnactEnvironment else {
            throw RunRefused("'\(invocation.selector)' drives a device, and this run has none")
        }
        
        return environment
    }
    
    // MARK: - Private
}

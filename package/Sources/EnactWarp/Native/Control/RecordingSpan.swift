//
//  RecordingSpan.swift
//  EnactWarp
//
//  Created by JSilver on 11/12/26.
//

import Digit
import Foundation
import Warp

// A recording kept in the out dir while a body runs, and what the body
// returned. A kept recording lands in the out dir and the recording log, a
// lost one in the log as lost. One lost is recording_failed, unless the body
// failed: that failure goes on as it was.
struct RecordingSpan {
    // MARK: - Property
    private let name: String
    private let ext: String
    
    // MARK: - Initializer
    init(name: String, ext: String) {
        self.name = name
        self.ext = ext
    }
    
    // MARK: - Public
    func record(
        in environment: EnactEnvironment,
        _ recording: (String) async throws -> Recorded<Warp.Value>
    ) async throws -> Warp.Value {
        let recorded: Recorded<Warp.Value>
        
        do {
            recorded = try await environment.outputDirectory.write(
                name,
                ext: ext,
                kept: { recorded in recorded.lost == nil }
            ) { destination in
                let recorded = try await recording(destination.path)
                
                // A kept recording is listed whether or not its body failed, since
                // a failed run is the one a recording is wanted for. A lost one is
                // logged as lost, and leaves no empty file behind.
                if let lost = recorded.lost {
                    environment.recordings.lose(destination.path, because: "\(lost)")
                } else {
                    environment.recordings.land(destination.path)
                }
                
                return recorded
            }
        } catch let unstarted as UnstartedRecording {
            throw StepFailure(.recordingFailed, "\(unstarted.reason)")
        }
        
        let returned = try recorded.outcome.get()
        
        if let lost = recorded.lost { throw StepFailure(.recordingFailed, "\(lost)") }
        
        return returned
    }
    
    // MARK: - Private
}

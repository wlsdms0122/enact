//
//  StreamVideo.swift
//  DigitCLI
//
//  Created by JSilver on 11/10/26.
//

import ArgumentParser
import Digit
import Foundation

struct StreamVideo: AsyncParsableCommand {
    // MARK: - Property
    static let configuration = CommandConfiguration(
        commandName: Operation.streamVideo.rawValue,
        abstract: "Stream the screen until this command is stopped.",
        discussion: """
            Writes the video to standard output, or to --output, and runs until \
            interrupted (Ctrl-C, or SIGTERM from whoever started it). h264 is an \
            Annex B elementary stream, which players and ffmpeg read as it is \
            (| ffplay -f h264 -). fmp4 is the same video in fragmented MP4, the \
            form a browser's Media Source Extensions take. A frame is sent each \
            time the screen changes, so a still screen sends none; --fps sends \
            that many a second instead. To act on the device while watching it, \
            run a session beside the stream.
            """
    )
    
    @OptionGroup var target: DeviceOption
    @Option(help: "h264 or fmp4") var format: VideoFormat = .h264
    @Option(help: "frames a second, instead of a frame each time the screen changes") var fps: Int?
    @Option(help: "file to write, instead of standard output") var output: String?
    
    // MARK: - Initializer
    // MARK: - Public
    func validate() throws {
        guard output != nil || isatty(STDOUT_FILENO) == 0 else {
            throw ValidationError("standard output is a terminal. Pipe it to a player or pass --output")
        }
    }
    
    func run() async throws {
        let destination = try destination()
        let device = try target.device()
        let signals = SignalWaiter([SIGINT, SIGTERM])
        defer { signals.disarm() }
        
        let streaming = try StreamVideoOperator(format: format, framesPerSecond: fps) { data in
            Self.write(data, to: destination)
        }
        let stream = try await device.run(streaming)
        
        await signals.wait()
        
        try await stream.stop()
        try destination.close()
    }
    
    // MARK: - Private
    private func destination() throws -> FileHandle {
        guard let output else { return .standardOutput }
        
        guard FileManager.default.createFile(atPath: output, contents: nil),
            let handle = FileHandle(forWritingAtPath: output)
        else {
            throw ValidationError("cannot write \(output)")
        }
        
        return handle
    }
    
    // A write that fails means whoever reads the video is gone, so the stream
    // ends with it, as a pipe's SIGPIPE would end it.
    private static func write(_ data: Data, to destination: FileHandle) {
        do {
            try destination.write(contentsOf: data)
        } catch {
            report("writing the video: \(error)")
            Foundation.exit(EXIT_FAILURE)
        }
    }
    
    private static func report(_ message: String) {
        FileHandle.standardError.write(Data("enact: \(message)\n".utf8))
    }
}

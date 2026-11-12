//
//  SimulatorObservation.swift
//  Digit
//
//  Created by JSilver on 8/16/26.
//

import CoreGraphics
import FBControlCore
import FBSimulatorAX
import FBSimulatorControl
import FBSimulatorVideo
import FBVideoCore
import Foundation

struct SimulatorObservation {
    // MARK: - Property
    var implementations: [Implementation] {
        [
            .perform(describeUI),
            .perform(describeScreen),
            .perform(screenshot),
            .perform(recordVideo),
            .perform(recordLog),
            .perform(streamVideo)
        ]
    }
    
    // Grid steps in points. A coarse grid only finds whether any remote content is on the
    // screen; a fine one collects it, an element at least this small apart from the
    // next.
    private static let remoteContentSearch = AccessibilityRemoteContentOptions(gridStepSize: 100)
    private static let remoteContentSweep = AccessibilityRemoteContentOptions(gridStepSize: 20)
    
    private let simulator: Simulator
    
    // MARK: - Initializer
    init(simulator: Simulator) {
        self.simulator = simulator
    }
    
    // MARK: - Public
    // MARK: - Private
    private func describeUI(_ operation: DescribeUIOperator) async throws -> [Element] {
        let reader = AccessibilityReader(simulator: simulator)
        let geometry = try await simulator.displays.configuration().activeGeometry()
        let found =
            if let point = operation.point {
                try await reader.read(.point(CGPoint(x: point.x, y: point.y)))
            } else {
                try await reader.read(.frontmost, remoteContent: Self.remoteContentSearch)
            }
        let rotated = geometry.rotation != .upright
        let springBoard =
            if rotated || (operation.point == nil && found.contains(where: \.holdsRemoteContent)) {
                try await springBoardProcess()
            } else {
                Int64?.none
            }
        let elements =
            if operation.point == nil {
                try await content(found, by: reader, springBoard: springBoard)
            } else {
                found
            }
        let frames = springBoard.flatMap { process in
            rotated ? SpringBoardFrames(process: process, rotation: geometry.rotation, upright: geometry.unrotatedPointSize) : nil
        }
        
        return try elements.map { element in try Element(element, springBoardFrames: frames) }
    }
    
    // The frontmost application with the content other processes draw inside it, as a
    // web view's, each found where a press at a point lands and added after the
    // application's own elements. SpringBoard's status bar is not the application's.
    private func content(
        _ found: [AccessibilityDocumentElement],
        by reader: AccessibilityReader,
        springBoard: Int64?
    ) async throws -> [AccessibilityDocumentElement] {
        let content = found.map { element in element.removingRemoteContent(of: springBoard) }
        
        guard content.contains(where: \.holdsRemoteContent) else { return content }
        
        return try await reader.read(.frontmost, remoteContent: Self.remoteContentSweep)
            .map { element in element.removingRemoteContent(of: springBoard) }
    }
    
    private func springBoardProcess() async throws -> Int64? {
        let launchctl = SimulatorLaunchCtlCommands(simulator: simulator)
        let services = try await launchctl.serviceNamesAndProcessIdentifiers(
            matching: try NSRegularExpression(pattern: "com\\.apple\\.SpringBoard")
        )
        
        return services["com.apple.SpringBoard"].map(Int64.init)
    }
    
    private func describeScreen(_: DescribeScreenOperator) async throws -> Screen {
        let size = try await simulator.displays.configuration().activeGeometry().pointSize
        
        return try Screen(width: size.width, height: size.height)
    }
    
    private func screenshot(_ operation: ScreenshotOperator) async throws -> Data {
        let configuration = ScreenshotConfiguration(encoding: ScreenshotEncoding(operation.format))
        
        return try await simulator.screenshot.take(configuration: configuration).imageData
    }
    
    private func recordVideo(_ operation: RecordVideoOperator) async throws -> Recording {
        nonisolated(unsafe) let recording = try await simulator.videoRecording
            .start(toFile: operation.path)
        
        return Recording {
            _ = try await recording.stop()
        }
    }
    
    private func recordLog(_ operation: RecordLogOperator) async throws -> Recording {
        try await LogStream(udid: simulator.udid).start(to: operation.path, matching: operation.predicate)
    }
    
    private func streamVideo(_ operation: StreamVideoOperator) async throws -> VideoStream {
        let configuration = VideoStreamConfiguration(
            format: VideoStreamFormat(operation.format),
            framesPerSecond: operation.framesPerSecond,
            rateControl: nil,
            scaleFactor: nil,
            keyFrameRate: nil
        )
        let stream = try await simulator.videoStream.create(
            configuration: configuration,
            to: SynchronousDataConsumer(consumer: operation.sink)
        )
        
        return VideoStream {
            try await stream.stopStreaming()
        }
    }
}

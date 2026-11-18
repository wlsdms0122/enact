//
//  RecordingBackend.swift
//  EnactTests
//
//  Created by JSilver on 10/31/26.
//

import Foundation
@testable import Digit

// A device that performs every operation by writing it down, or fails each
// with the error it was given. It looks at a screen of 400 by 800 holding the
// elements it was given, and its videos fail to close with the error given for that.
final class RecordingBackend: DeviceBackend, @unchecked Sendable {
    // MARK: - Property
    let info = DeviceInfo(udid: "udid-enact", name: "stub", osVersion: "iOS 26.0", state: .booted)
    let screen: Screen
    let elements: [Element]
    let failure: (any Error)?
    let closing: (any Error)?
    
    var performed: [any Operator] { lock.withLock { written } }
    
    var dispatchTable: DispatchTable {
        DispatchTable([
            .perform { [self] (operation: TapOperator) in try record(operation) },
            .perform { [self] (operation: LongPressOperator) in try record(operation) },
            .perform { [self] (operation: TypeTextOperator) in try record(operation) },
            .perform { [self] (operation: MoveSliderOperator) in try record(operation) },
            .perform { [self] (operation: PressKeyOperator) in try record(operation) },
            .perform { [self] (operation: PressButtonOperator) in try record(operation) },
            .perform { [self] (operation: SwipeOperator) in try record(operation) },
            .perform { [self] (operation: DragOperator) in try record(operation) },
            .perform { [self] (operation: RespondBiometricOperator) in try record(operation) },
            .perform { [self] (operation: LaunchAppOperator) in
                try record(operation)
                
                return 1
            },
            .perform { [self] (operation: TerminateAppOperator) in try record(operation) },
            .perform { [self] (operation: AppStateOperator) in
                try record(operation)
                
                return .foreground
            },
            .perform { [self] (operation: UninstallAppOperator) in try record(operation) },
            .perform { [self] (operation: InstallAppOperator) in try record(operation) },
            .perform { [self] (operation: OpenURLOperator) in try record(operation) },
            .perform { [self] (operation: PushNotificationOperator) in try record(operation) },
            .perform { [self] (operation: SetAppearanceOperator) in try record(operation) },
            .perform { [self] (operation: SetContentSizeOperator) in try record(operation) },
            .perform { [self] (operation: SetContrastOperator) in try record(operation) },
            .perform { [self] (operation: SetPrivacyOperator) in try record(operation) },
            .perform { [self] (operation: SetLocationOperator) in try record(operation) },
            .perform { [self] (operation: SetStatusBarOperator) in try record(operation) },
            .perform { [self] (operation: SetOrientationOperator) in try record(operation) },
            .perform { [self] (operation: SetHingeOperator) in try record(operation) },
            .perform { [self] (operation: SetHardwareKeyboardOperator) in try record(operation) },
            .perform { [self] (operation: SetAppAccessibilityOperator) in try record(operation) },
            .perform { [self] (operation: AppAccessibilityOperator) in
                try record(operation)
                
                return .enabled
            },
            .perform { [self] (operation: AddMediaOperator) in try record(operation) },
            .perform { [self] (operation: AddCertificateOperator) in try record(operation) },
            .perform { [self] (operation: ResetKeychainOperator) in try record(operation) },
            .perform { [self] (operation: SetPasteboardOperator) in try record(operation) },
            .perform { [self] (operation: ReadPasteboardOperator) in
                try record(operation)
                
                return "on the pasteboard"
            },
            .perform { [self] (operation: ScreenshotOperator) in
                try record(operation)
                
                return Data("png".utf8)
            },
            .perform { [self] (operation: RecordVideoOperator) in
                try record(operation)
                
                return Recording { [closing] in
                    if let closing { throw closing }
                }
            },
            .perform { [self] (operation: RecordLogOperator) in
                try record(operation)
                
                return Recording { [closing] in
                    if let closing { throw closing }
                }
            },
            .perform { [self] (_: DescribeScreenOperator) in screen },
            .perform { [self] (_: DescribeUIOperator) in elements }
        ])
    }
    
    private let lock = NSLock()
    private var written: [any Operator] = []
    
    // MARK: - Initializer
    init(elements: [Element] = [], failure: (any Error)? = nil, closing: (any Error)? = nil) throws {
        self.screen = try Screen(width: 400, height: 800)
        self.elements = elements
        self.failure = failure
        self.closing = closing
    }
    
    // MARK: - Public
    // MARK: - Private
    private func record(_ operation: any Operator) throws {
        if let failure { throw failure }
        
        lock.withLock { written.append(operation) }
    }
}

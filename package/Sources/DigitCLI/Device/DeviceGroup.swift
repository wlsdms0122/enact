//
//  DeviceGroup.swift
//  DigitCLI
//
//  Created by JSilver on 8/16/26.
//

import ArgumentParser
import Digit
import Foundation

public struct DeviceGroup: AsyncParsableCommand {
    // MARK: - Property
    public static let configuration = CommandConfiguration(
        commandName: "device",
        abstract: "Do one thing to one device.",
        discussion: """
            These take no lock. Whoever holds a device does the work from its \
            own process, and a command that locked would block that process. \
            So a scenario in progress keeps out other holders, not a stray \
            `enact device tap`. A caller that has to keep others out takes the \
            lock itself; lock-path says where it is.
            
            `enact run` holds the device for a whole scenario, and a device \
            already held that way is reported busy rather than waited for.
            """,
        subcommands: operations
    )
    
    private static let operations: [any ParsableCommand.Type] = [
        ListTargets.self,
        Lookup.self,
        LockPath.self,
        Capabilities.self,
        Create.self,
        Clone.self,
        Delete.self,
        Boot.self,
        Shutdown.self,
        Reboot.self,
        Erase.self,
        InstallApp.self,
        UninstallApp.self,
        LaunchApp.self,
        TerminateApp.self,
        ReadAppState.self,
        ListApps.self,
        AppContainer.self,
        AppGroups.self,
        PushNotification.self,
        OpenURL.self,
        DescribeUI.self,
        DescribeScreen.self,
        Screenshot.self,
        RecordVideo.self,
        RecordLog.self,
        StreamVideo.self,
        RecordInput.self,
        Session.self,
        Tap.self,
        LongPress.self,
        Swipe.self,
        Drag.self,
        TypeText.self,
        PressKey.self,
        PressButton.self,
        MoveSlider.self,
        RespondBiometric.self,
        SetAppearance.self,
        SetContentSize.self,
        SetContrast.self,
        SetPrivacy.self,
        SetLocation.self,
        SetStatusBar.self,
        SetOrientation.self,
        SetHinge.self,
        SetHardwareKeyboard.self,
        ReadAppAccessibility.self,
        SetAppAccessibility.self,
        AddMedia.self,
        AddCertificate.self,
        ResetKeychain.self,
        ReadPasteboard.self,
        SetPasteboard.self
    ]
    
    // MARK: - Initializer
    public init() {}
    
    // MARK: - Public
    // MARK: - Private
}

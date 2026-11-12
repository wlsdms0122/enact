//
//  Operation.swift
//  Digit
//
//  Created by JSilver on 8/16/26.
//

import Foundation

public enum Operation: String, CaseIterable, Sendable {
    case boot
    case shutdown
    case reboot
    case erase
    case installApp = "install-app"
    case uninstallApp = "uninstall-app"
    case launchApp = "launch-app"
    case terminateApp = "terminate-app"
    case appState = "app-state"
    case listApps = "list-apps"
    case appContainer = "app-container"
    case appGroups = "app-groups"
    case openURL = "open-url"
    case pushNotification = "push-notification"
    case describeUI = "describe-ui"
    case describeScreen = "describe-screen"
    case screenshot
    case recordVideo = "record-video"
    case recordLog = "record-log"
    case streamVideo = "stream-video"
    case tap
    case longPress = "long-press"
    case swipe
    case drag
    case typeText = "type-text"
    case pressKey = "press-key"
    case pressButton = "press-button"
    case moveSlider = "move-slider"
    case respondBiometric = "respond-biometric"
    case setAppearance = "set-appearance"
    case setContentSize = "set-content-size"
    case setContrast = "set-contrast"
    case setPrivacy = "set-privacy"
    case setLocation = "set-location"
    case setStatusBar = "set-status-bar"
    case setOrientation = "set-orientation"
    case setHinge = "set-hinge"
    case setHardwareKeyboard = "set-hardware-keyboard"
    case appAccessibility = "app-accessibility"
    case setAppAccessibility = "set-app-accessibility"
    case addMedia = "add-media"
    case addCertificate = "add-certificate"
    case resetKeychain = "reset-keychain"
    case readPasteboard = "read-pasteboard"
    case setPasteboard = "set-pasteboard"
}

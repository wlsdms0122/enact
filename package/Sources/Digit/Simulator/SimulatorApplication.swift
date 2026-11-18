//
//  SimulatorApplication.swift
//  Digit
//
//  Created by JSilver on 8/16/26.
//

import FBControlCore
import FBSimulatorControl
import FBSimulatorServices
import Foundation

struct SimulatorApplication {
    // MARK: - Property
    var implementations: [Implementation] {
        [
            .perform(installApp),
            .perform(uninstallApp),
            .perform(launchApp),
            .perform(terminateApp),
            .perform(appState),
            .perform(listApps),
            .perform(appContainer),
            .perform(appGroups),
            .perform(openURL),
            .perform(pushNotification)
        ]
    }
    
    private let simulator: Simulator
    private let containers = AppContainerReader()
    
    // MARK: - Initializer
    init(simulator: Simulator) {
        self.simulator = simulator
    }
    
    // MARK: - Public
    // MARK: - Private
    private func installApp(_ operation: InstallAppOperator) async throws {
        _ = try await simulator.application.install(atPath: operation.path)
    }
    
    private func uninstallApp(_ operation: UninstallAppOperator) async throws {
        try await simulator.application.uninstall(bundleID: operation.bundleID)
    }
    
    private func launchApp(_ operation: LaunchAppOperator) async throws -> Int32 {
        var arguments = operation.arguments
        
        if let locale = operation.locale {
            arguments += ["-AppleLocale", locale]
        }
        
        if let language = operation.language {
            arguments += ["-AppleLanguages", "(\(language))"]
        }
        
        let configuration = ApplicationLaunchConfiguration(
            bundleID: operation.bundleID,
            bundleName: nil,
            arguments: arguments,
            environment: operation.environment,
            waitForDebugger: false,
            launchMode: .relaunchIfRunning
        )
        
        return try await simulator.application.launch(configuration).processIdentifier
    }
    
    // An app that is not running is already where terminating it leaves it, and
    // so is one that ends between the look and the kill.
    private func terminateApp(_ operation: TerminateAppOperator) async throws {
        guard try await isRunning(operation.bundleID) else { return }
        
        do {
            try await simulator.application.kill(bundleID: operation.bundleID)
        } catch {
            guard try await isRunning(operation.bundleID) else { return }
            
            throw error
        }
    }
    
    // The screen shows the app whose process the frontmost element belongs to.
    private func appState(_ operation: AppStateOperator) async throws -> AppState {
        guard let process = try await simulator.application.running()[operation.bundleID] else {
            return .notRunning
        }
        
        let frontmost = try await AccessibilityReader(simulator: simulator).read(.frontmost)
        
        return frontmost.contains { element in (element.pid ?? nil) == Int64(process) } ? .foreground : .background
    }
    
    private func isRunning(_ bundleID: String) async throws -> Bool {
        try await simulator.application.running()[bundleID] != nil
    }
    
    private func listApps(_: ListAppsOperator) async throws -> [InstalledApp] {
        try await simulator.application.installed().map { app in
            InstalledApp(
                bundleID: app.bundle.identifier,
                name: app.bundle.name,
                bundlePath: app.bundle.path,
                dataContainer: app.dataContainer,
                installKind: app.installTypeString
            )
        }
    }
    
    private func appContainer(_ operation: AppContainerOperator) async throws -> String {
        try containers.path(
            udid: simulator.udid,
            bundleID: operation.bundleID,
            container: operation.container.argument
        )
    }
    
    private func appGroups(_ operation: AppGroupsOperator) async throws -> [String: String] {
        try containers.groups(udid: simulator.udid, bundleID: operation.bundleID)
    }
    
    private func openURL(_ operation: OpenURLOperator) async throws {
        try await simulator.lifecycle.open(operation.url)
    }
    
    private func pushNotification(_ operation: PushNotificationOperator) async throws {
        try await simulator.notification.sendPush(
            forBundleID: operation.bundleID,
            jsonPayload: operation.payload
        )
    }
}

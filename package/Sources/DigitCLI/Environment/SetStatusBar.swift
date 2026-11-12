//
//  SetStatusBar.swift
//  DigitCLI
//
//  Created by JSilver on 8/16/26.
//

import ArgumentParser
import Digit
import Foundation

package struct SetStatusBar: DeviceCommand {
    // MARK: - Property
    package static let configuration = CommandConfiguration(
        commandName: Operation.setStatusBar.rawValue,
        abstract: "Override what the status bar shows.",
        discussion:
            "With no options given, the override is cleared and the bar goes back to normal."
    )
    
    @OptionGroup package var target: DeviceOption
    @Option(help: "e.g. 9:41") package var time: String?
    @Option(name: .customLong("data-network"), help: "network type") package var dataNetwork: DataNetwork?
    @Option(name: .customLong("wifi-mode"), help: "searching, failed or active") package var wifiMode: WifiMode?
    @Option(name: .customLong("wifi-bars"), help: "0…3") package var wifiBars: Int?
    @Option(name: .customLong("cellular-mode"), help: "not-supported, searching, failed or active") package var cellularMode: CellularMode?
    @Option(name: .customLong("cellular-bars"), help: "0…4") package var cellularBars: Int?
    @Option(name: .customLong("operator"), help: "carrier name") package var operatorName: String?
    @Option(name: .customLong("battery-state"), help: "discharging, charging or charged") package var batteryState: BatteryState?
    @Option(name: .customLong("battery-level"), help: "0…100") package var batteryLevel: Int?
    
    // MARK: - Initializer
    package init() {}
    
    // MARK: - Public
    package func perform(on device: Device) async throws -> Empty {
        let statusBar = try SetStatusBarOperator(
            time: time,
            dataNetwork: dataNetwork,
            wifiMode: wifiMode,
            wifiBars: wifiBars,
            cellularMode: cellularMode,
            cellularBars: cellularBars,
            operatorName: operatorName,
            batteryState: batteryState,
            batteryLevel: batteryLevel
        )
        
        try await device.run(statusBar)
        
        return Empty()
    }
    
    // MARK: - Private
}

//
//  StatusBarOverride+Operator.swift
//  Digit
//
//  Created by JSilver on 11/5/26.
//

import FBSimulatorControl

// The override holds each mode and state as the number CoreSimulator gives
// it (`SimDevice`'s status bar overrides).
extension StatusBarOverride {
    // What the operation sets, over what the override held.
    mutating func apply(_ operation: SetStatusBarOperator) {
        if let time = operation.time { timeString = time }
        if let network = operation.dataNetwork { dataNetworkType = Self.number(of: network) }
        if let mode = operation.wifiMode { wiFiMode = Self.number(of: mode) }
        if let bars = operation.wifiBars { wiFiBars = bars }
        if let mode = operation.cellularMode { cellularMode = Self.number(of: mode) }
        if let bars = operation.cellularBars { cellularBars = bars }
        if let name = operation.operatorName { operatorName = name }
        if let state = operation.batteryState { batteryState = Self.number(of: state) }
        if let level = operation.batteryLevel { batteryLevel = level }
    }
    
    private static func number(of network: DataNetwork) -> Int {
        switch network {
        case .hide: 0
        case .wifi: 1
        case .threeG: 6
        case .fourG: 7
        case .lte: 8
        case .lteAdvanced: 9
        case .ltePlus: 10
        case .fiveG: 11
        case .fiveGPlus: 12
        case .fiveGUltraWideband: 13
        case .fiveGUltraCapacity: 14
        }
    }
    
    private static func number(of mode: WifiMode) -> Int {
        switch mode {
        case .searching: 1
        case .failed: 2
        case .active: 3
        }
    }
    
    private static func number(of mode: CellularMode) -> Int {
        switch mode {
        case .notSupported: 0
        case .searching: 1
        case .failed: 2
        case .active: 3
        }
    }
    
    private static func number(of state: BatteryState) -> Int {
        switch state {
        case .discharging: 0
        case .charging: 1
        case .charged: 2
        }
    }
}

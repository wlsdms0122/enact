//
//  SetStatusBarOperator.swift
//  Digit
//
//  Created by JSilver on 8/16/26.
//

import Foundation

public struct SetStatusBarOperator: Operator {
    // MARK: - Property
    public static let operation = Operation.setStatusBar
    
    public let time: String?
    public let dataNetwork: DataNetwork?
    public let wifiMode: WifiMode?
    public let wifiBars: Int?
    public let cellularMode: CellularMode?
    public let cellularBars: Int?
    public let operatorName: String?
    public let batteryState: BatteryState?
    public let batteryLevel: Int?
    
    public var isEmpty: Bool {
        time == nil && dataNetwork == nil && wifiMode == nil && wifiBars == nil
            && cellularMode == nil && cellularBars == nil && operatorName == nil
            && batteryState == nil && batteryLevel == nil
    }
    
    // MARK: - Initializer
    public init(
        time: String? = nil,
        dataNetwork: DataNetwork? = nil,
        wifiMode: WifiMode? = nil,
        wifiBars: Int? = nil,
        cellularMode: CellularMode? = nil,
        cellularBars: Int? = nil,
        operatorName: String? = nil,
        batteryState: BatteryState? = nil,
        batteryLevel: Int? = nil
    ) throws {
        try Self.check(wifiBars, "wifi bars", within: 0...3)
        try Self.check(cellularBars, "cellular bars", within: 0...4)
        try Self.check(batteryLevel, "battery level", within: 0...100)
        
        self.time = time
        self.dataNetwork = dataNetwork
        self.wifiMode = wifiMode
        self.wifiBars = wifiBars
        self.cellularMode = cellularMode
        self.cellularBars = cellularBars
        self.operatorName = operatorName
        self.batteryState = batteryState
        self.batteryLevel = batteryLevel
    }
    
    // MARK: - Public
    // MARK: - Private
    private static func check(
        _ value: Int?,
        _ field: String,
        within range: ClosedRange<Int>
    ) throws {
        guard let value else { return }
        
        guard range.contains(value) else {
            throw DigitError.outOfRange(field: field, value: value, allowed: range)
        }
    }
}

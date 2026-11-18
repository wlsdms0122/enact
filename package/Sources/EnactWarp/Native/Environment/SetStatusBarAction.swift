//
//  SetStatusBarAction.swift
//  EnactWarp
//
//  Created by JSilver on 10/31/26.
//

import Digit
import Foundation
import Warp

struct SetStatusBarAction: EnactAction {
    enum Parameters: Int, ParameterSet {
        case time
        case dataNetwork
        case wifiMode
        case wifiBars
        case cellularMode
        case cellularBars
        case operatorName
        case batteryState
        case batteryLevel
        
        // MARK: - Property
        var declared: Parameter {
            switch self {
            case .time:
                Parameter(name: "time")
            
            case .dataNetwork:
                Parameter(name: "data_network")
            
            case .wifiMode:
                Parameter(name: "wifi_mode")
            
            case .wifiBars:
                Parameter(name: "wifi_bars")
            
            case .cellularMode:
                Parameter(name: "cellular_mode")
            
            case .cellularBars:
                Parameter(name: "cellular_bars")
            
            case .operatorName:
                Parameter(name: "operator_name")
            
            case .batteryState:
                Parameter(name: "battery_state")
            
            case .batteryLevel:
                Parameter(name: "battery_level")
            }
        }
        
        // MARK: - Initializer
        // MARK: - Public
        // MARK: - Private
    }
    
    // MARK: - Property
    static let operations: Set<Digit.Operation> = [.setStatusBar]
    
    // MARK: - Initializer
    // MARK: - Public
    func act(_ invocation: Invocation<Self>, in environment: EnactEnvironment) async throws -> Warp.Value {
        try await environment.device.run(
            try SetStatusBarOperator(
                time: invocation.string(.time),
                dataNetwork: try invocation.optionalWord(.dataNetwork, in: EnactVocabulary.dataNetwork),
                wifiMode: try invocation.optionalWord(.wifiMode, in: EnactVocabulary.wifiMode),
                wifiBars: try invocation.integer(.wifiBars),
                cellularMode: try invocation.optionalWord(.cellularMode, in: EnactVocabulary.cellularMode),
                cellularBars: try invocation.integer(.cellularBars),
                operatorName: invocation.string(.operatorName),
                batteryState: try invocation.optionalWord(.batteryState, in: EnactVocabulary.batteryState),
                batteryLevel: try invocation.integer(.batteryLevel)
            )
        )
        
        return .null
    }
    
    // MARK: - Private
}

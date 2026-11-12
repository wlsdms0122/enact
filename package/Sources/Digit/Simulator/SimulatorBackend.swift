//
//  SimulatorBackend.swift
//  Digit
//
//  Created by JSilver on 8/16/26.
//

import FBControlCore
import FBSimulatorControl
import Foundation

final class SimulatorBackend: DeviceBackend {
    // MARK: - Property
    var info: DeviceInfo { DeviceInfo(simulator) }
    
    var dispatchTable: DispatchTable {
        DispatchTable(
            SimulatorLifecycle(simulator: simulator).implementations
                + SimulatorApplication(simulator: simulator).implementations
                + SimulatorObservation(simulator: simulator).implementations
                + SimulatorInput(simulator: simulator).implementations
                + SimulatorEnvironment(simulator: simulator).implementations
                + SimulatorPasteboard(simulator: simulator).implementations
        )
    }
    
    private let simulator: Simulator
    
    // MARK: - Initializer
    init(simulator: Simulator) {
        self.simulator = simulator
    }
    
    // MARK: - Public
    // MARK: - Private
}

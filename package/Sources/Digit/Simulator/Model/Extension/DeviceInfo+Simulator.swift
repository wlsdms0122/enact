//
//  DeviceInfo+Simulator.swift
//  Digit
//
//  Created by JSilver on 11/5/26.
//

import FBSimulatorControl

extension DeviceInfo {
    init(_ simulator: Simulator) {
        self.init(
            udid: simulator.udid,
            name: simulator.name,
            osVersion: simulator.osVersion.name.rawValue,
            state: DeviceState(simulator.state)
        )
    }
}

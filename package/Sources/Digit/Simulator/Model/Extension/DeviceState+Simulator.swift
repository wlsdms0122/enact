//
//  DeviceState+Simulator.swift
//  Digit
//
//  Created by JSilver on 8/16/26.
//

import FBControlCore

extension DeviceState {
    init(_ state: TargetState) {
        switch state {
        case .creating:
            self = .creating
        
        case .shutdown:
            self = .shutdown
        
        case .booting:
            self = .booting
        
        case .booted:
            self = .booted
        
        case .shuttingDown:
            self = .shuttingDown
        
        default:
            self = .unknown
        }
    }
}

//
//  SimulatorHIDButton+Button.swift
//  Digit
//
//  Created by JSilver on 8/16/26.
//

import FBSimulatorControl

extension SimulatorHIDButton {
    init(_ button: Button) {
        switch button {
        case .home:
            self = .homeButton
        
        case .lock:
            self = .lock
        
        case .side:
            self = .sideButton
        
        case .siri:
            self = .siri
        
        case .applePay:
            self = .applePay
        }
    }
}

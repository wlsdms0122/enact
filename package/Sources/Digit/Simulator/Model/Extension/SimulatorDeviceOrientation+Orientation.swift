//
//  SimulatorDeviceOrientation+Orientation.swift
//  Digit
//
//  Created by JSilver on 11/5/26.
//

import FBSimulatorControl

extension SimulatorDeviceOrientation {
    init(_ orientation: Orientation) {
        switch orientation {
        case .portrait:
            self = .portrait
        
        case .portraitUpsideDown:
            self = .portraitUpsideDown
        
        case .landscapeLeft:
            self = .landscapeLeft
        
        case .landscapeRight:
            self = .landscapeRight
        }
    }
}

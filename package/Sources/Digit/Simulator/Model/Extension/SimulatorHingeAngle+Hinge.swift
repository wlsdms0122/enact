//
//  SimulatorHingeAngle+Hinge.swift
//  Digit
//
//  Created by JSilver on 11/5/26.
//

import FBSimulatorControl

extension SimulatorHingeAngle {
    init(_ hinge: Hinge) throws {
        switch hinge {
        case .folded:
            try self.init(degrees: 0)
        
        case .unfolded:
            try self.init(degrees: 180)
        }
    }
}

//
//  SimulatorAppearance+Appearance.swift
//  Digit
//
//  Created by JSilver on 8/16/26.
//

import FBSimulatorServices

extension SimulatorAppearance {
    init(_ appearance: Appearance) {
        switch appearance {
        case .light:
            self = .light
        
        case .dark:
            self = .dark
        }
    }
}

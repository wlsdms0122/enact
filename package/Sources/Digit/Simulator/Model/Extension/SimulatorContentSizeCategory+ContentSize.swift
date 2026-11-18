//
//  SimulatorContentSizeCategory+ContentSize.swift
//  Digit
//
//  Created by JSilver on 8/16/26.
//

import FBSimulatorServices

extension SimulatorContentSizeCategory {
    init(_ contentSize: ContentSize) {
        switch contentSize {
        case .extraSmall:
            self = .extraSmall
        
        case .small:
            self = .small
        
        case .medium:
            self = .medium
        
        case .large:
            self = .large
        
        case .extraLarge:
            self = .extraLarge
        
        case .extraExtraLarge:
            self = .extraExtraLarge
        
        case .extraExtraExtraLarge:
            self = .extraExtraExtraLarge
        
        case .accessibilityMedium:
            self = .accessibilityMedium
        
        case .accessibilityLarge:
            self = .accessibilityLarge
        
        case .accessibilityExtraLarge:
            self = .accessibilityExtraLarge
        
        case .accessibilityExtraExtraLarge:
            self = .accessibilityExtraExtraLarge
        
        case .accessibilityExtraExtraExtraLarge:
            self = .accessibilityExtraExtraExtraLarge
        }
    }
}

//
//  ObservedScreen.swift
//  Enact
//
//  Created by JSilver on 11/10/26.
//

import Digit
import Foundation

// One look: the screen's size, and every element on it in reading order,
// each before the elements inside it.
package struct ObservedScreen: Sendable, Equatable {
    // MARK: - Property
    package let screen: Screen
    package let elements: [ObservedElement]
    
    // MARK: - Initializer
    package init(_ screen: Screen, elements: [ObservedElement]) {
        self.screen = screen
        self.elements = elements
    }
    
    // MARK: - Public
    // MARK: - Private
}

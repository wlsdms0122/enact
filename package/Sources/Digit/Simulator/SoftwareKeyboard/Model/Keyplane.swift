//
//  Keyplane.swift
//  Digit
//
//  Created by JSilver on 11/10/26.
//

import Foundation

// The keys the software keyboard shows at one moment, and where each is.
struct Keyplane: Equatable {
    // MARK: - Property
    let state: KeyboardState
    let points: [SoftwareKey: Point]
    
    // MARK: - Initializer
    init(_ keys: [Element]) {
        let named = keys.compactMap { key in SoftwareKey(key).map { software in (software, key) } }
        let points = Dictionary(
            named.map { software, key in (software, key.frame.center) },
            uniquingKeysWith: { first, _ in first }
        )
        
        self.state = KeyboardState(
            keys: Set(points.keys),
            nextKeyboard: named.first { software, _ in software == .nextKeyboard }?.1.value
        )
        self.points = points
    }
    
    // MARK: - Public
    // MARK: - Private
}

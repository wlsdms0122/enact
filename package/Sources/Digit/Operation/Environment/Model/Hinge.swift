//
//  Hinge.swift
//  Digit
//
//  Created by JSilver on 11/5/26.
//

import Foundation

// How a device that folds stands: closed on its outer screen or opened flat.
public enum Hinge: String, Sendable, CaseIterable {
    case folded
    case unfolded
}

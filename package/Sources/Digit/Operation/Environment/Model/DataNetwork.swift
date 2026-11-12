//
//  DataNetwork.swift
//  Digit
//
//  Created by JSilver on 11/5/26.
//

import Foundation

// The data network the status bar names.
public enum DataNetwork: String, Sendable, CaseIterable {
    case hide
    case wifi
    case threeG = "three-g"
    case fourG = "four-g"
    case lte
    case lteAdvanced = "lte-advanced"
    case ltePlus = "lte-plus"
    case fiveG = "five-g"
    case fiveGPlus = "five-g-plus"
    case fiveGUltraWideband = "five-g-ultra-wideband"
    case fiveGUltraCapacity = "five-g-ultra-capacity"
}

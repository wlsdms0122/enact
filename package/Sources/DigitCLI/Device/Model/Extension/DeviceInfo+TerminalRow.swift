//
//  DeviceInfo+TerminalRow.swift
//  DigitCLI
//
//  Created by JSilver on 11/5/26.
//

import Digit

extension DeviceInfo {
    // A device as one row of the plain output, the same wherever it is listed.
    var terminalRow: [String] {
        [state.rawValue, udid, name, osVersion]
    }
}

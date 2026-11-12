//
//  DeviceBackend.swift
//  Digit
//
//  Created by JSilver on 8/16/26.
//

import Foundation

protocol DeviceBackend: AnyObject {
    var info: DeviceInfo { get }
    var dispatchTable: DispatchTable { get }
}

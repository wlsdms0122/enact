//
//  DeviceSet.swift
//  Digit
//
//  Created by JSilver on 8/16/26.
//

import FBControlCore
import FBSimulatorControl
import Foundation

public struct DeviceSet {
    // MARK: - Property
    public static let bootedAlias = "booted"
    
    private static let loading = NSLock()
    nonisolated(unsafe) private static var isLoaded = false
    
    // MARK: - Initializer
    public init() {}
    
    // MARK: - Public
    public func loadFrameworks() throws {
        Self.loading.lock()
        defer { Self.loading.unlock() }
        
        guard !Self.isLoaded else { return }
        
        try SimulatorControlFrameworkLoader.essentialFrameworks.loadPrivateFrameworks(nil)
        try SimulatorControlFrameworkLoader.xcodeFrameworks.loadPrivateFrameworks(nil)
        
        Self.isLoaded = true
    }
    
    public func devices() throws -> [DeviceInfo] {
        try backends().map(\.info)
    }
    
    public func resolve(udid: String) throws -> String {
        let devices = try devices()
        
        return devices[try index(of: udid, among: devices)].udid
    }
    
    public func open(udid: String) throws -> Device {
        let backends = try backends()
        let found = try index(of: udid, among: backends.map(\.info))
        
        return Device(backend: backends[found])
    }
    
    // A new device of a type, on a runtime, the newest the type runs where
    // none is named, each named as `simctl list devicetypes` and
    // `simctl list runtimes` name them.
    public func create(named name: String, deviceType: String, runtime: String?) throws -> DeviceInfo {
        let created = try Simctl().run(["create", name, deviceType] + (runtime.map { runtime in [runtime] } ?? []))
        
        return try info(of: created)
    }
    
    public func clone(udid: String, named name: String) throws -> DeviceInfo {
        let cloned = try Simctl().run(["clone", try resolve(udid: udid), name])
        
        return try info(of: cloned)
    }
    
    public func delete(udid: String) throws {
        _ = try Simctl().run(["delete", try resolve(udid: udid)])
    }
    
    // MARK: - Private
    // The device simctl printed the udid of.
    private func info(of printed: String) throws -> DeviceInfo {
        let udid = printed.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard let found = try devices().first(where: { device in device.udid == udid }) else {
            throw DigitError.targetNotFound(udid: udid)
        }
        
        return found
    }
    
    private func index(of udid: String, among devices: [DeviceInfo]) throws -> Int {
        guard udid == Self.bootedAlias else {
            guard let found = devices.firstIndex(where: { $0.udid == udid }) else {
                throw DigitError.targetNotFound(udid: udid)
            }
            
            return found
        }
        
        let booted = devices.indices.filter { devices[$0].state == .booted }
        
        guard booted.count == 1 else {
            throw DigitError.ambiguousAlias(
                alias: Self.bootedAlias,
                candidates: booted.map { devices[$0] }
            )
        }
        
        return booted[0]
    }
    
    private func backends() throws -> [DeviceBackend] {
        try loadFrameworks()
        
        let configuration = SimulatorControlConfiguration(deviceSetPath: nil, logger: nil)
        let bootstrap = try SimulatorControlBootstrap(configuration: configuration)
        
        return bootstrap.set.allSimulators.map { SimulatorBackend(simulator: $0) }
    }
}

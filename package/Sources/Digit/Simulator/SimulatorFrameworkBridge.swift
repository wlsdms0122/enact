//
//  SimulatorFrameworkBridge.swift
//  Digit
//
//  Created by JSilver on 11/1/26.
//

import CryptoKit
import FBControlCore
import Foundation
import MachO

// idb's iOS guest, which it runs inside a simulator to ask what the host cannot see,
// such as which accessibility display is the active one. Package.swift links the
// executable into this image as a section, and `install()` writes it where idb looks,
// once per process, before the first operation that runs it.
enum SimulatorFrameworkBridge {
    // MARK: - Property
    private static let name = "SimulatorFrameworkBridge-iOS"
    private static let segment = "__TEXT"
    private static let section = "__sim_bridge"

    private static let installation = Result { try written() }

    // MARK: - Public
    static func install() throws {
        try installation.get()
    }

    // MARK: - Private
    private static func written() throws {
        guard let executable = embedded() else { return }

        let directory = try directory(for: executable)
        let path = directory.appending(path: name).path

        if !FileManager.default.isExecutableFile(atPath: path) {
            try write(executable, to: path, in: directory)
        }

        BundledResources.hostDirectoryPath = directory.path
    }

    private static func embedded() -> Data? {
        let header = #dsohandle.assumingMemoryBound(to: mach_header_64.self)
        var size: UInt = 0

        guard let start = getsectiondata(header, segment, section, &size), size > 0 else {
            return nil
        }

        return Data(bytesNoCopy: start, count: Int(size), deallocator: .none)
    }

    // Named by content, so binaries carrying different guests never share a file and
    // one already written is never stale.
    private static func directory(for executable: Data) throws -> URL {
        let digest = SHA256.hash(data: executable).prefix(8)
            .map { String(format: "%02x", $0) }
            .joined()

        return try FileManager.default
            .url(for: .cachesDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            .appending(path: "digit/\(digest)")
    }

    // Written aside and renamed into place, so a process racing this one never runs a
    // half-written guest.
    private static func write(_ executable: Data, to path: String, in directory: URL) throws {
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)

        let staging = directory.appending(path: "\(name).\(UUID().uuidString)").path

        try executable.write(to: URL(filePath: staging))
        try FileManager.default.setAttributes([.posixPermissions: 0o755], ofItemAtPath: staging)

        guard rename(staging, path) == 0 else {
            let failure = POSIXError(POSIXErrorCode(rawValue: errno) ?? .EIO)

            try? FileManager.default.removeItem(atPath: staging)

            throw failure
        }
    }
}

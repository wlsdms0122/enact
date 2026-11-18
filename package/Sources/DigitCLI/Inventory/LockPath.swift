//
//  LockPath.swift
//  DigitCLI
//
//  Created by JSilver on 8/16/26.
//

import ArgumentParser
import Digit
import Foundation

struct LockPath: AsyncParsableCommand {
    // MARK: - Property
    static let configuration = CommandConfiguration(
        commandName: "lock-path",
        abstract: "Print the lock file that holds this device exclusive.",
        discussion: """
            Exclusive access is a protocol, not a library: whoever holds a \
            device flocks this file, non-blocking, and never unlinks it. Other \
            participants lock it directly, and this command tells them where it \
            is instead of leaving them to re-derive the rule. The udid \
            is resolved first, so the alias and the udid it names lock the \
            same file. Note that a holder does the work itself: there is no \
            re-entering the lock through another participant.
            """
    )
    
    @OptionGroup var target: DeviceOption
    
    // MARK: - Initializer
    // MARK: - Public
    func run() async throws {
        print(try DeviceLock().path(for: DeviceSet().resolve(udid: target.udid)).path)
    }
    
    // MARK: - Private
}

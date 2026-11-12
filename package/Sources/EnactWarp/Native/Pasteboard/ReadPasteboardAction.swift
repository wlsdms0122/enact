//
//  ReadPasteboardAction.swift
//  EnactWarp
//
//  Created by JSilver on 11/1/26.
//

import Digit
import Foundation
import Warp

// Reads the text on the pasteboard, what the app copied.
struct ReadPasteboardAction: EnactAction {
    typealias Parameters = NoParameters
    
    // MARK: - Property
    static let operations: Set<Digit.Operation> = [.readPasteboard]
    
    // MARK: - Initializer
    // MARK: - Public
    func act(_ invocation: Invocation<Self>, in environment: EnactEnvironment) async throws -> Warp.Value {
        .string(try await environment.device.run(ReadPasteboardOperator()))
    }
    
    // MARK: - Private
}

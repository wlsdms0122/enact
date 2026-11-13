//
//  LookAction.swift
//  EnactWarp
//
//  Created by JSilver on 10/31/26.
//

import Digit
import Foundation
import Warp

// One read of the screen: its size, and every element on it in reading
// order, each before the elements inside it.
struct LookAction: EnactAction {
    typealias Parameters = NoParameters
    
    // MARK: - Property
    static let operations: Set<Digit.Operation> = [.describeScreen, .describeUI]
    
    // MARK: - Initializer
    // MARK: - Public
    func act(_ invocation: Invocation<Self>, in environment: EnactEnvironment) async throws -> Warp.Value {
        let screen = try await environment.device.run(DescribeScreenOperator())
        let tree = try await environment.device.run(DescribeUIOperator())
        
        return try Look(screen: screen, tree: tree).value
    }
    
    // MARK: - Private
}

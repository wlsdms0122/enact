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
        let elements = try await environment.device.run(DescribeUIOperator())
        let fields: [(name: Warp.Name, value: Warp.Value)] = [
            (name: "width", value: .double(screen.width)),
            (name: "height", value: .double(screen.height)),
            (name: "elements", value: .array(try flattened(elements, under: []).map(Warp.Value.init)))
        ]
        
        return try .holding(fields, named: EnactVocabulary.screenType)
    }
    
    // MARK: - Private
    private func flattened(_ elements: [Element], under path: [Int]) -> [Snapshot] {
        elements.enumerated().flatMap { index, element in
            [Snapshot(element, at: path + [index])] + flattened(element.children, under: path + [index])
        }
    }
}

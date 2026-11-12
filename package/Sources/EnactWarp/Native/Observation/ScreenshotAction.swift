//
//  ScreenshotAction.swift
//  EnactWarp
//
//  Created by JSilver on 10/31/26.
//

import Digit
import Foundation
import Warp

struct ScreenshotAction: EnactAction {
    enum Parameters: Int, ParameterSet {
        case name
        
        // MARK: - Property
        var declared: Parameter {
            switch self {
            case .name:
                Parameter(name: "name")
            }
        }
        
        // MARK: - Initializer
        // MARK: - Public
        // MARK: - Private
    }
    
    // MARK: - Property
    static let operations: Set<Digit.Operation> = [.screenshot]
    
    // MARK: - Initializer
    // MARK: - Public
    func act(_ invocation: Invocation<Self>, in environment: EnactEnvironment) async throws -> Warp.Value {
        let image = try await environment.device.run(ScreenshotOperator(format: .png))
        let written = try await environment.outputDirectory.write(invocation.string(.name) ?? "shot", ext: "png") { destination in
            try image.write(to: destination)
            
            return destination
        }
        
        return .string(written.path)
    }
    
    // MARK: - Private
}

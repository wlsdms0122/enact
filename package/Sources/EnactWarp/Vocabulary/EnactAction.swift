//
//  EnactAction.swift
//  EnactWarp
//
//  Created by JSilver on 10/31/26.
//

import Digit
import Foundation
import Warp

// A native verb that drives the run's device. What the device says no to
// comes out as the step failure of its kind; an interruption stays a
// cancellation, which no catch in a scenario takes.
protocol EnactAction: Warp.Effect {
    // What the verb asks the device for, so a run can be refused before it
    // starts on a device that does none of it.
    static var operations: Set<Digit.Operation> { get }
    
    init()
    
    func act(_ invocation: Invocation<Self>, in environment: EnactEnvironment) async throws -> Warp.Value
}

extension EnactAction {
    func run(_ invocation: Invocation<Self>) async throws -> Warp.Value {
        let environment = try EnactEnvironment.from(invocation)
        
        do {
            return try await act(invocation, in: environment)
        } catch DigitError.interrupted {
            throw CancellationError()
        } catch let error as DigitError {
            throw StepFailure(error)
        } catch let error as CapabilityError {
            throw StepFailure(.deviceRefused, "\(error)")
        }
    }
}

//
//  RunningTask.swift
//  Enact
//
//  Created by JSilver on 10/31/26.
//

import Foundation
import Warp

// The task a run executes in, held so that a stop noticed inside the run
// can cancel it.
final class RunningTask: @unchecked Sendable {
    // MARK: - Property
    private let lock = NSLock()
    private var task: Task<Result<Warp.Value, any Error>, Never>?
    private var cancelled = false
    
    // MARK: - Initializer
    init() {}
    
    // MARK: - Public
    func run(_ body: @escaping @Sendable () async throws -> Warp.Value) async -> Result<Warp.Value, any Error> {
        let task = Task { () -> Result<Warp.Value, any Error> in
            do {
                return .success(try await body())
            } catch {
                return .failure(error)
            }
        }
        
        // A stop that came before the task was held still cancels it.
        lock.withLock {
            self.task = task
            
            if cancelled { task.cancel() }
        }
        
        return await withTaskCancellationHandler {
            await task.value
        } onCancel: {
            task.cancel()
        }
    }
    
    func cancel() {
        lock.withLock {
            cancelled = true
            
            return task
        }?.cancel()
    }
    
    // MARK: - Private
}

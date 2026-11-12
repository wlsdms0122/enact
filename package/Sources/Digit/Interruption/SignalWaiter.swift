//
//  SignalWaiter.swift
//  Digit
//
//  Created by JSilver on 8/16/26.
//

import Foundation

public final class SignalWaiter: @unchecked Sendable {
    // MARK: - Property
    // Whether one of the signals arrived, waited for or not.
    public var hasArrived: Bool {
        lock.lock()
        defer { lock.unlock() }
        
        return received
    }
    
    private let signals: [Int32]
    private let lock = NSLock()
    
    private var sources: [DispatchSourceSignal] = []
    private var previous: [Int32: sig_t?] = [:]
    private var arrived: (() -> Void)?
    private var received = false
    private var abandoned = false
    
    // MARK: - Initializer
    public init(_ signals: [Int32]) {
        self.signals = signals
        
        lock.lock()
        
        for number in signals {
            let source = DispatchSource.makeSignalSource(signal: number, queue: .global())
            source.setEventHandler { [weak self] in self?.fire() }
            source.resume()
            
            sources.append(source)
        }
        
        for number in signals {
            previous.updateValue(signal(number, SIG_IGN), forKey: number)
        }
        
        lock.unlock()
    }
    
    // MARK: - Public
    public func wait() async {
        await withTaskCancellationHandler {
            await withCheckedContinuation { continuation in
                lock.lock()
                
                if received || abandoned {
                    lock.unlock()
                    continuation.resume()
                    
                    return
                }
                
                arrived = { continuation.resume() }
                
                lock.unlock()
            }
        } onCancel: {
            lock.lock()
            
            abandoned = true
            let arrived = self.arrived
            self.arrived = nil
            
            lock.unlock()
            
            arrived?()
        }
    }
    
    public func disarm() {
        lock.lock()
        
        let sources = self.sources
        let previous = self.previous
        self.sources = []
        self.previous = [:]
        
        lock.unlock()
        
        sources.forEach { $0.cancel() }
        
        for (number, handler) in previous {
            signal(number, handler ?? SIG_DFL)
        }
    }
    
    // MARK: - Private
    private func fire() {
        lock.lock()
        
        received = true
        let arrived = self.arrived
        self.arrived = nil
        
        lock.unlock()
        
        arrived?()
    }
}

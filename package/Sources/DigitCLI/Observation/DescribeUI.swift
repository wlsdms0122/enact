//
//  DescribeUI.swift
//  DigitCLI
//
//  Created by JSilver on 8/16/26.
//

import ArgumentParser
import Digit
import Foundation

struct DescribeUI: DeviceCommand {
    // MARK: - Property
    static let configuration = CommandConfiguration(
        commandName: Operation.describeUI.rawValue,
        abstract: "Dump the on-screen accessibility tree.",
        discussion: """
            What another process draws inside the app, as a web view's content, \
            is found by asking for the element at points a grid apart, and \
            follows the app's own elements with none inside another; an element \
            smaller than the grid can be missed. The read turns application \
            accessibility on where it is off, and leaves it on. \
            With --point, describes only the element under it. Both coordinates \
            arrive together so that half a point cannot be asked for.
            """
    )
    
    @OptionGroup var target: DeviceOption
    @Option(help: "x,y of a single element to describe") var point: Point?
    @OptionGroup var output: OutputOption
    
    // MARK: - Initializer
    // MARK: - Public
    func perform(on device: Device) async throws -> [Element] {
        try await device.run(DescribeUIOperator(at: point))
    }
    
    func show(_ answer: [Element]) throws {
        try output.emit(answer) { answer.map { plain($0) }.joined(separator: "\n") }
    }
    
    // MARK: - Private
    private func plain(_ element: Element, depth: Int = 0) -> String {
        let indent = String(repeating: "  ", count: depth)
        var line = "\(indent)\(element.role.rawValue)"
        
        if let label = element.label, !label.isEmpty { line += "  \"\(label)\"" }
        if let value = element.value, !value.isEmpty { line += "  =\(value)" }
        if let id = element.id, !id.isEmpty { line += "  #\(id)" }
        
        line += "  (\(Int(element.frame.center.x)),\(Int(element.frame.center.y)))"
        
        if !element.enabled { line += "  [disabled]" }
        if !element.actions.isEmpty { line += "  {\(element.actions.joined(separator: ","))}" }
        
        return ([line] + element.children.map { plain($0, depth: depth + 1) })
            .joined(separator: "\n")
    }
}

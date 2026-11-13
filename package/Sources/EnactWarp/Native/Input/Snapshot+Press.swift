//
//  Snapshot+Press.swift
//  EnactWarp
//
//  Created by JSilver on 11/1/26.
//

import Digit
import Foundation

extension Snapshot {
    // MARK: - Public
    // Where a press on this snapshot lands, at fractions of its frame or its
    // middle. A press is refused where it would do nothing, or touch nothing
    // it was aimed at: on a disabled element, off the screen, or where the
    // element answering at that point is neither this one nor one inside it,
    // as when the screen moved since the look or an element reaching past it
    // is drawn over it. An element drawn within its frame, or one that
    // accessibility does not answer for, is not told apart.
    func pressed(at fraction: Point?, on device: Device) async throws -> Point {
        guard enabled else {
            throw StepFailure(.referenceUnfit, "\(named) is not enabled, so a press on it does nothing")
        }
        
        let point = frame.point(at: fraction)
        let screen = try await device.run(DescribeScreenOperator())
        
        guard screen.contains(point) else {
            throw StepFailure(
                .referenceUnfit,
                "\(named) would be pressed at \(point.x.spelled), \(point.y.spelled), "
                    + "off the screen of \(screen.width.spelled) by \(screen.height.spelled)"
            )
        }
        
        let answering = try await device.run(DescribeUIOperator(at: point)).first
        
        guard let answering, frame.contains(answering.frame) else {
            let found = answering.map { element in "\(element.named) answers there" } ?? "nothing answers there"
            
            throw StepFailure(
                .referenceUnfit,
                "\(named) would be pressed at \(point.x.spelled), \(point.y.spelled), but \(found)"
            )
        }
        
        return point
    }
    
    // The snapshot as a refusal names it: by its label, its id, or its role.
    var named: String {
        if let label, !label.isEmpty { return "the snapshot '\(label)'" }
        if let id, !id.isEmpty { return "the snapshot #\(id)" }
        
        return "the \(role) snapshot"
    }
    
    // MARK: - Private
}

private extension Double {
    // A coordinate in points, whole where it is whole.
    var spelled: String { rounded() == self ? String(Int(self)) : String(self) }
}

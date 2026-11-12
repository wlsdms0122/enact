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
    // middle. A disabled element, or a press that would land off the screen,
    // is refused: the press would do nothing, or touch nothing it was aimed at.
    func pressed(at fraction: Point?, on screen: Screen) throws -> Point {
        guard enabled else {
            throw StepFailure(.referenceUnfit, "\(named) is not enabled, so a press on it does nothing")
        }
        
        let point = frame.point(at: fraction)
        
        guard screen.contains(point) else {
            throw StepFailure(
                .referenceUnfit,
                "\(named) would be pressed at \(point.x.spelled), \(point.y.spelled), "
                    + "off the screen of \(screen.width.spelled) by \(screen.height.spelled)"
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
}

private extension Double {
    // A coordinate in points, whole where it is whole.
    var spelled: String { rounded() == self ? String(Int(self)) : String(self) }
}

//
//  ObservedScreen+Input.swift
//  EnactCLI
//
//  Created by JSilver on 11/13/26.
//

import Digit
import Enact
import EnactWarp
import Foundation

extension ObservedScreen {
    // MARK: - Property
    // The software keyboard's keys the look shows.
    var keys: [Snapshot] {
        elements.map(\.snapshot).filter { snapshot in snapshot.role == .key }
    }
    
    // MARK: - Public
    // The element of the look a recorded press landed on: what accessibility
    // answered there, or the innermost element holding it, as a button holds its
    // text, that the application showed where the look saw it when it was pressed.
    // A look of a screen that moved on before the press names nothing.
    func element(pressedBy event: InputEvent) -> ObservedElement? {
        guard case let .gesture(gesture) = event, let point = gesture.point, let answered = gesture.element else { return nil }
        
        let shown = gesture.application.map(Self.flattened) ?? []
        let touched = Element.Frame(x: point.x, y: point.y, width: 0, height: 0)
        
        return elements.last { element in
            let snapshot = element.snapshot
            let same = { (other: Element) in
                other.label == snapshot.label && other.id == snapshot.id
                    && Self.holds(other.frame, snapshot.frame) && Self.holds(snapshot.frame, other.frame)
            }
            
            return same(answered)
                || (Self.holds(snapshot.frame, answered.frame) && Self.holds(snapshot.frame, touched) && shown.contains(where: same))
        }
    }
    
    // MARK: - Private
    // Within half a point, as two reads of one frame differ in their last digits.
    private static func holds(_ outer: Element.Frame, _ inner: Element.Frame) -> Bool {
        let slack = 0.5
        
        return inner.x >= outer.x - slack
            && inner.y >= outer.y - slack
            && inner.x + inner.width <= outer.x + outer.width + slack
            && inner.y + inner.height <= outer.y + outer.height + slack
    }
    
    private static func flattened(_ element: Element) -> [Element] {
        [element] + element.children.flatMap(flattened)
    }
}

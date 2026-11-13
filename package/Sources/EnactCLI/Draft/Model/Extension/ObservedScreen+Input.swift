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
        
        return elements.last { element in Self.same(answered, element.snapshot) }
            ?? elements.last { element in
                let snapshot = element.snapshot
                
                return Self.holds(snapshot.frame, answered.frame)
                    && Self.holds(snapshot.frame, touched)
                    && shown.contains { other in Self.same(other, snapshot) }
            }
    }
    
    // MARK: - Private
    // Whether a recorded element is the one a look read, by the name a look gives
    // it and its frame.
    private static func same(_ element: Element, _ snapshot: Snapshot) -> Bool {
        let read = Snapshot(element, at: [])
        
        return read.label == snapshot.label && read.id == snapshot.id
            && holds(element.frame, snapshot.frame) && holds(snapshot.frame, element.frame)
    }
    
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

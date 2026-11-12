//
//  PressedElement.swift
//  EnactCLI
//
//  Created by JSilver on 11/10/26.
//

import Enact
import EnactWarp
import Foundation

// The element of a look a press lands on, as element_at read it, with what
// catches it and where it stands among the elements that catch catches. The
// catch is the first that holds of this element alone, else the first under
// which it is the first in reading order, as wait_for returns the first that
// holds, else the first.
struct PressedElement {
    // MARK: - Property
    let element: ObservedElement
    let `catch`: ElementCatch
    // How many elements of the look the catch holds of, and the place of this
    // one among them in reading order, from 0.
    let matched: Int
    let place: Int
    // The nearest element it is inside that has a label or an identifier.
    let ancestor: ObservedElement?
    
    // MARK: - Initializer
    // Nil where the look has no such element, or it shows nothing to catch it
    // by.
    init?(_ hit: ObservedElement, in seen: ObservedScreen) {
        guard let index = seen.elements.firstIndex(where: { element in Self.same(element.snapshot, hit.snapshot) }),
            let first = ElementCatch.catches(of: seen.elements[index]).first
        else {
            return nil
        }
        
        let element = seen.elements[index]
        let before = seen.elements[..<index]
        let matched = { (candidate: ElementCatch) in seen.elements.count { other in candidate.holds(of: other) } }
        let place = { (candidate: ElementCatch) in before.count { other in candidate.holds(of: other) } }
        let catches = ElementCatch.catches(of: element)
        let caught = catches.first { candidate in matched(candidate) == 1 }
            ?? catches.first { candidate in place(candidate) == 0 }
            ?? first
        
        self.element = element
        self.catch = caught
        self.matched = matched(caught)
        self.place = place(caught)
        // An element comes after the elements it is inside in reading order.
        self.ancestor = before
            .filter { other in
                other.snapshot.indexPath.count < element.snapshot.indexPath.count
                    && element.snapshot.indexPath.starts(with: other.snapshot.indexPath)
            }
            .last { other in !(other.snapshot.label ?? "").isEmpty || !(other.snapshot.id ?? "").isEmpty }
    }
    
    // MARK: - Public
    // MARK: - Private
    // Two reads of one element: element_at's stands in no look, so its place
    // in the tree is not compared.
    private static func same(_ one: Snapshot, _ other: Snapshot) -> Bool {
        one.id == other.id
            && one.label == other.label
            && one.value == other.value
            && one.role == other.role
            && one.frame == other.frame
    }
}

//
//  Element.Frame+Containment.swift
//  EnactWarp
//
//  Created by JSilver on 11/13/26.
//

import Digit
import Foundation

extension Element.Frame {
    // Whether another frame lies wholly within this one.
    func contains(_ inner: Element.Frame) -> Bool {
        inner.x >= x
            && inner.y >= y
            && inner.x + inner.width <= x + width
            && inner.y + inner.height <= y + height
    }
}

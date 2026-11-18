//
//  Element.Frame+Fraction.swift
//  EnactWarp
//
//  Created by JSilver on 10/31/26.
//

import Digit
import Foundation

extension Element.Frame {
    // A point given as fractions of the frame, its middle where none is given,
    // on whole points.
    func point(at fraction: Point?) -> Point {
        let fraction = fraction ?? Point(x: 0.5, y: 0.5)
        
        return Point(x: (x + width * fraction.x).rounded(), y: (y + height * fraction.y).rounded())
    }
}

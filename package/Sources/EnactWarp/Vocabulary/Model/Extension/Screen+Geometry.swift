//
//  Screen+Geometry.swift
//  EnactWarp
//
//  Created by JSilver on 10/31/26.
//

import Digit
import Foundation

extension Screen {
    // A point given as fractions of the screen's width and height.
    func point(at fraction: Point) -> Point {
        Point(x: fraction.x * width, y: fraction.y * height)
    }
    
    // A point of the screen as fractions of its width and height.
    package func fraction(of point: Point) -> Point {
        Point(x: point.x / width, y: point.y / height)
    }
    
    // The whole screen as a frame.
    package var frame: Element.Frame {
        Element.Frame(x: 0, y: 0, width: width, height: height)
    }
    
    // Whether a point lands on the screen.
    func contains(_ point: Point) -> Bool {
        point.x >= 0 && point.x < width && point.y >= 0 && point.y < height
    }
    
    // The part of a frame the screen shows, nil where it shows none of it.
    func visible(_ frame: Element.Frame) -> Element.Frame? {
        let (left, top) = (max(frame.x, 0), max(frame.y, 0))
        let (right, bottom) = (min(frame.x + frame.width, width), min(frame.y + frame.height, height))
        
        guard right > left, bottom > top else { return nil }
        
        return Element.Frame(x: left, y: top, width: right - left, height: bottom - top)
    }
}

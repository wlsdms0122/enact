//
//  Origin+Place.swift
//  Enact
//
//  Created by JSilver on 11/5/26.
//

import Foundation
import Warp
import WarpSyntax
import WarpYAML

extension Origin {
    // Where in the text a place in the document stands, read through the keys
    // the document writes it with. Nil for a place that is no spot in a
    // document.
    func position(of place: Place) -> Position? {
        guard case let .array(written)? = place.value, written.count == 2, case let .array(keys) = written[1] else {
            return nil
        }
        
        let steps = keys.compactMap { key -> Step? in
            switch key {
            case let .string(name):
                .key(name)
            
            case let .int(position):
                .index(position)
            
            default:
                nil
            }
        }
        
        guard steps.count == keys.count else { return nil }
        
        return reading(steps).position
    }
}

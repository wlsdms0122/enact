//
//  Element+Naming.swift
//  EnactWarp
//
//  Created by JSilver on 11/13/26.
//

import Digit
import Foundation

extension Element {
    // The element as a refusal names it: by its label, its id, or its role.
    var named: String {
        if let label, !label.isEmpty { return "the element '\(label)'" }
        if let id, !id.isEmpty { return "the element #\(id)" }
        
        return "the \(role) element"
    }
}

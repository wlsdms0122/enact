//
//  Array+Snapshot.swift
//  EnactWarp
//
//  Created by JSilver on 10/31/26.
//

import Foundation
import Warp

extension Array where Element == Snapshot {
    package init(_ value: Warp.Value) throws {
        guard case let .array(items) = value else {
            throw RunRefused("\(value) is not a list of \(EnactVocabulary.snapshotType)")
        }
        
        self = try items.map(Snapshot.init)
    }
}

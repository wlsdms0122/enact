//
//  Value+Snapshot.swift
//  EnactWarp
//
//  Created by JSilver on 10/31/26.
//

import Digit
import Foundation
import Warp

extension Warp.Value {
    package init(_ snapshot: Snapshot) throws {
        let fields: [(name: Warp.Name, value: Warp.Value)] = [
            (name: "id", value: Self.text(snapshot.id)),
            (name: "label", value: Self.text(snapshot.label)),
            (name: "value", value: Self.text(snapshot.value)),
            (name: "role", value: try EnactVocabulary.role.value(of: snapshot.role)),
            (name: "enabled", value: .bool(snapshot.enabled)),
            (name: "actions", value: .array(snapshot.actions.map(Warp.Value.string))),
            (name: "frame", value: try Warp.Value(snapshot.frame)),
            (name: "track", value: try snapshot.track.map(Warp.Value.init) ?? .null),
            (name: "index_path", value: .array(snapshot.indexPath.map(Warp.Value.int)))
        ]
        
        self = try .holding(fields, named: EnactVocabulary.snapshotType)
    }
    
    private init(_ frame: Element.Frame) throws {
        self = try .holding(
            [
                (name: "x", value: .double(frame.x)),
                (name: "y", value: .double(frame.y)),
                (name: "width", value: .double(frame.width)),
                (name: "height", value: .double(frame.height))
            ],
            named: EnactVocabulary.frameType
        )
    }
    
    private static func text(_ text: String?) -> Warp.Value {
        text.map(Warp.Value.string) ?? .null
    }
}

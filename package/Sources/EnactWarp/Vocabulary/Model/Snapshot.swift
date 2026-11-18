//
//  Snapshot.swift
//  EnactWarp
//
//  Created by JSilver on 10/31/26.
//

import Digit
import Foundation
import Warp

// An element as one look saw it, the `Enact.Snapshot` a scenario holds. A
// slider carries its rail, the frame a thumb travels along. The index path is
// where the element sits in the tree the look read: its place among its
// parent's children, after its parent's own path.
package struct Snapshot: Sendable, Equatable, Codable {
    private enum CodingKeys: String, CodingKey {
        case id
        case label
        case value
        case role
        case enabled
        case actions
        case frame
        case track
        case indexPath = "index_path"
    }
    
    // MARK: - Property
    package let id: String?
    package let label: String?
    package let value: String?
    package let role: Role
    package let enabled: Bool
    package let actions: [String]
    package let frame: Element.Frame
    package let track: Element.Frame?
    package let indexPath: [Int]
    
    // MARK: - Initializer
    package init(
        id: String?,
        label: String?,
        value: String?,
        role: Role,
        enabled: Bool,
        actions: [String],
        frame: Element.Frame,
        track: Element.Frame?,
        indexPath: [Int]
    ) {
        self.id = id
        self.label = label
        self.value = value
        self.role = role
        self.enabled = enabled
        self.actions = actions
        self.frame = frame
        self.track = track
        self.indexPath = indexPath
    }
    
    package init(_ element: Element, at indexPath: [Int]) {
        self.init(
            id: element.id.map(Self.trimmed),
            label: element.label.map(Self.trimmed),
            value: element.value.map(Self.trimmed),
            role: element.role,
            enabled: element.enabled,
            actions: element.actions,
            frame: element.frame,
            track: element.role == .slider ? Self.rail(of: element).frame : nil,
            indexPath: indexPath
        )
    }
    
    package init(_ value: Warp.Value) throws {
        guard case let .struct(held) = value,
            let role = held["role"].flatMap(EnactVocabulary.role.word(of:)),
            case let .bool(enabled) = held["enabled"],
            case let .array(actions) = held["actions"],
            case let .array(indexPath) = held["index_path"]
        else {
            throw RunRefused("\(value) is not an \(EnactVocabulary.snapshotType)")
        }
        
        self.init(
            id: try Self.text(held["id"]),
            label: try Self.text(held["label"]),
            value: try Self.text(held["value"]),
            role: role,
            enabled: enabled,
            actions: try actions.compactMap(Self.text),
            frame: try Self.frame(held["frame"]),
            track: held["track"] == .null ? nil : try Self.frame(held["track"]),
            indexPath: try indexPath.map { place in
                guard case let .int(index) = place else { throw RunRefused("\(place) is no place in an index path") }
                
                return index
            }
        )
    }
    
    // MARK: - Public
    // MARK: - Private
    private static func rail(of element: Element) -> Element {
        guard let inner = element.children.first(where: { child in child.role == .slider }) else { return element }
        
        return rail(of: inner)
    }
    
    private static func trimmed(_ text: String) -> String {
        text.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    private static func text(_ value: Warp.Value?) throws -> String? {
        switch value {
        case let .string(text):
            text
        
        case .null, nil:
            nil
        
        default:
            throw RunRefused("a snapshot holds \(value.map(String.init(describing:)) ?? "nothing") where text is declared")
        }
    }
    
    private static func frame(_ value: Warp.Value?) throws -> Element.Frame {
        guard case let .struct(held) = value,
            case let .double(x) = held["x"],
            case let .double(y) = held["y"],
            case let .double(width) = held["width"],
            case let .double(height) = held["height"]
        else {
            throw RunRefused("\(value.map(String.init(describing:)) ?? "nothing") is not an \(EnactVocabulary.frameType)")
        }
        
        return Element.Frame(x: x, y: y, width: width, height: height)
    }
}

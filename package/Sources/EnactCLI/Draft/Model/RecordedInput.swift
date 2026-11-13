//
//  RecordedInput.swift
//  EnactCLI
//
//  Created by JSilver on 11/13/26.
//

import Digit
import EnactWarp
import Foundation

// Recorded input as a draft writes it, each input by the verb that does the same.
// The software keyboard's keys tapped in a row are held as the text they type, and
// written as one type_text when input of another kind comes or the input ends.
struct RecordedInput {
    // What a tap on the software keyboard does to the text being typed. The keys
    // that change the keyboard type nothing of their own, as type_text presses them
    // itself to reach a character.
    enum KeyTap: Equatable {
        case character(String)
        case erase
        case changesKeyboard
    }
    
    // MARK: - Property
    // The keys that change which keys the keyboard shows, by the start of their
    // labels.
    private static let keyboardChanging = ["shift", "more", "numbers", "letters", "symbols", "next keyboard", "emoji", "dictate"]
    
    // What the device names a swipe by, before the way it went.
    private static let swipe = "swipe "
    
    private var typed = ""
    
    // MARK: - Initializer
    // MARK: - Public
    // What to write of an input: nothing while it adds to the text being typed. A
    // key that types no text, as a return or a delete with nothing typed, is a tap
    // on the key like any other.
    mutating func written(_ event: InputEvent, keys: [Snapshot]) -> [DraftOperation] {
        switch Self.keyTap(event, keys: keys) {
        case let .character(character):
            typed += character
            
            return []
        
        case .erase where !typed.isEmpty:
            typed.removeLast()
            
            return []
        
        case .changesKeyboard:
            return []
        
        case .erase, nil:
            return remaining() + Self.operations(for: event)
        }
    }
    
    // The text typed and not yet written.
    mutating func remaining() -> [DraftOperation] {
        guard !typed.isEmpty else { return [] }
        
        defer { typed = "" }
        
        return [.call(.call("type_text", [DraftNode.Entry("text", .quoted(typed))]))]
    }
    
    // MARK: - Private
    // Nil for an input that is no tap on the software keyboard. The key is what
    // accessibility answered, else the look's key at the point, as the device can
    // answer with no key while the keyboard redraws its keys. A tap inside the
    // keyboard that names no key types nothing and is taken to change it.
    private static func keyTap(_ event: InputEvent, keys: [Snapshot]) -> KeyTap? {
        guard case let .gesture(gesture) = event, gesture.names == ["tap"], let point = gesture.point else { return nil }
        
        let answered = gesture.element.flatMap { element in element.role == .key ? element.label : nil }
        let label = answered ?? keys.last { key in contains(key.frame, point) }?.label
        
        guard let label else {
            guard let keyboard = bounds(of: keys.map(\.frame)), contains(keyboard, point) else { return nil }
            
            return .changesKeyboard
        }
        
        if label.count == 1 { return .character(label) }
        if label == "space" { return .character(" ") }
        if label == "delete" { return .erase }
        if keyboardChanging.contains(where: { prefix in label.lowercased().hasPrefix(prefix) }) { return .changesKeyboard }
        
        return nil
    }
    
    private static func bounds(of frames: [Element.Frame]) -> Element.Frame? {
        guard let left = frames.map(\.x).min(),
            let top = frames.map(\.y).min(),
            let right = frames.map({ frame in frame.x + frame.width }).max(),
            let bottom = frames.map({ frame in frame.y + frame.height }).max()
        else {
            return nil
        }
        
        return Element.Frame(x: left, y: top, width: right - left, height: bottom - top)
    }
    
    private static func contains(_ frame: Element.Frame, _ point: Point) -> Bool {
        frame.x...(frame.x + frame.width) ~= point.x && frame.y...(frame.y + frame.height) ~= point.y
    }
    
    private static func operations(for event: InputEvent) -> [DraftOperation] {
        switch event {
        case let .gesture(gesture):
            [gestured(gesture)]
        
        case let .button(button):
            [.call(.call("press_button", [DraftNode.Entry("button", .enumCase(EnactVocabulary.button.caseName(of: button)))]))]
        
        case let .key(key):
            [.call(.call(
                "press_key",
                [DraftNode.Entry("key", .quoted(key.key))]
                    + (key.modifiers.isEmpty
                        ? []
                        : [DraftNode.Entry("modifiers", .sequence(key.modifiers.map { modifier in .enumCase(EnactVocabulary.modifier.caseName(of: modifier)) }))])
            ))]
        
        case let .activation(bundleID):
            bundleID.isEmpty ? [] : [.comment("\(bundleID) came to the front")]
        
        case let .orientation(orientation):
            [.comment("the interface turned to \(orientation)")]
        }
    }
    
    private static func gestured(_ gesture: InputEvent.Gesture) -> DraftOperation {
        let name = gesture.names.first ?? ""
        
        guard let point = gesture.point else { return .comment("the device gave no point for the gesture '\(name)'") }
        
        let duration = (gesture.duration * 10).rounded() / 10
        
        switch name {
        case "tap":
            return .tap(point)
        
        case "long press":
            return .longPress(point, duration: duration)
        
        default:
            guard name.hasPrefix(swipe), let direction = Direction(rawValue: String(name.dropFirst(swipe.count))) else {
                return .comment("no verb does the gesture '\(name)' at \(point.x),\(point.y)")
            }
            
            return .swipe(point, direction: direction, duration: max(duration, 0.1))
        }
    }
}

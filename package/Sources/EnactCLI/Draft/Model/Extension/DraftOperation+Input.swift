//
//  DraftOperation+Input.swift
//  EnactCLI
//
//  Created by JSilver on 11/13/26.
//

import Digit
import EnactWarp
import Foundation

extension DraftOperation {
    // A tap on one of the software keyboard's keys, as what it adds to the text the
    // keys type. The keys that change the keyboard type nothing of their own, as
    // type_text presses them itself to reach a character.
    enum KeyTap: Equatable {
        case character(String)
        case changesKeyboard
        case key(String)
    }
    
    // MARK: - Property
    // The software keyboard's keys that change which keys it shows, by the start of
    // their labels.
    private static let keyboardChanging = ["shift", "more", "numbers", "letters", "symbols", "next keyboard", "emoji", "dictate"]
    // The device's flags of the modifiers a key can be pressed with.
    private static let modifierFlags: [(Modifier, UInt64)] = [
        (.shift, 1 << 17), (.control, 1 << 18), (.option, 1 << 19), (.command, 1 << 20)
    ]
    // Characters a hardware key makes that press_key names by a word.
    private static let keyWords: [Character: String] = [
        "\r": "return", "\n": "return", "\t": "tab", "\u{1B}": "escape", "\u{7F}": "delete", "\u{8}": "delete",
        "\u{F700}": "up", "\u{F701}": "down", "\u{F702}": "left", "\u{F703}": "right"
    ]
    
    // MARK: - Public
    // What a recorded input did, as the draft writes it. A tap on a software key is
    // read by `keyTap` instead, so the keys typed in a row are written as one text.
    static func written(_ event: InputEvent) -> [DraftOperation] {
        switch event {
        case let .gesture(gesture):
            gestured(gesture)
        
        case let .keys(keys):
            [pressed(keys)]
        
        case let .activation(bundleID):
            bundleID.isEmpty ? [] : [.comment("\(bundleID) came to the front")]
        
        case let .orientation(orientation):
            [.comment("the interface turned to \(orientation)")]
        }
    }
    
    // Nil for an input that is no tap on a software key. A tap inside the keyboard
    // that answers with no key, as one while the keyboard is still coming up, types
    // nothing and is taken to change the keyboard.
    static func keyTap(_ event: InputEvent, keyboard: Element.Frame?) -> KeyTap? {
        guard case let .gesture(gesture) = event, gesture.names == ["tap"], let point = gesture.point else { return nil }
        
        guard let key = gesture.element, key.role == .key, let label = key.label else {
            guard let keyboard,
                keyboard.x...(keyboard.x + keyboard.width) ~= point.x,
                keyboard.y...(keyboard.y + keyboard.height) ~= point.y
            else {
                return nil
            }
            
            return .changesKeyboard
        }
        
        if label.count == 1 { return .character(label) }
        if label == "space" { return .character(" ") }
        if keyboardChanging.contains(where: { prefix in label.lowercased().hasPrefix(prefix) }) { return .changesKeyboard }
        
        return .key(label)
    }
    
    // MARK: - Private
    private static func gestured(_ gesture: InputEvent.Gesture) -> [DraftOperation] {
        guard let name = gesture.names.first else { return [] }
        
        if name == "XCUIEventTypeMenuButtonDown" {
            return [.call(.call("press_button", [DraftNode.Entry("button", .enumCase(EnactVocabulary.button.caseName(of: .home)))]))]
        }
        
        // The device names the other halves of a button's press on their own.
        if name.hasPrefix("XCUIEventType") { return [] }
        
        guard let point = gesture.point else { return [.comment("the device gave no point for the gesture '\(name)'")] }
        
        let duration = (gesture.duration * 10).rounded() / 10
        
        switch name {
        case "tap":
            return [.tap(point)]
        
        case "double tap":
            return [.tap(point), .tap(point)]
        
        case "long press":
            return [.longPress(point, duration: duration)]
        
        case "swipe up", "swipe down", "swipe left", "swipe right":
            return [.swipe(point, direction: String(name.dropFirst("swipe ".count)), duration: max(duration, 0.1))]
        
        default:
            return [.comment("no verb does the gesture '\(name)' at \(point.x),\(point.y)")]
        }
    }
    
    // A character a key makes with no modifier but shift, which the character
    // already holds, is pressed as it is; one held with another is pressed by the
    // key it makes alone.
    private static func pressed(_ keys: InputEvent.Keys) -> DraftOperation {
        let held = modifierFlags.filter { _, flag in keys.modifiers & flag != 0 }.map { modifier, _ in modifier }
        let plain = held.allSatisfy { modifier in modifier == .shift }
        let text = plain ? keys.characters : keys.unmodified
        
        guard text.count == 1, let character = text.first else {
            return .comment("no verb presses the keys making '\(keys.characters)'")
        }
        
        let key = keyWords[character] ?? text
        let modifiers = plain ? [] : held
        
        return .call(.call(
            "press_key",
            [DraftNode.Entry("key", .quoted(key))]
                + (modifiers.isEmpty
                    ? []
                    : [DraftNode.Entry("modifiers", .sequence(modifiers.map { modifier in .enumCase(EnactVocabulary.modifier.caseName(of: modifier)) }))])
        ))
    }
}

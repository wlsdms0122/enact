//
//  ScenarioDraft.swift
//  EnactCLI
//
//  Created by JSilver on 11/10/26.
//

import Digit
import Enact
import EnactWarp
import Foundation

// A scenario written from what was done to a device: a module whose main
// does it again in order, each press named by what the screen showed under
// it, and each screen a press led on to waited for.
struct ScenarioDraft {
    // Whether a press may have led on to a screen not yet waited for.
    private enum Wait {
        case settled
        // The look before the press, nil where it failed.
        case open(before: ObservedScreen?)
    }
    
    // MARK: - Property
    private let name: String
    private var statements: [DraftStatement] = []
    private var names: Set<String> = []
    private var wait: Wait = .settled
    
    // Whether the look after a press is still to be waited for, so the next
    // look is to be taken even for a line that presses nothing.
    var awaitsScreen: Bool {
        if case .open = wait { true } else { false }
    }
    
    // The module as a file holds it.
    var text: String {
        let head = ["name: \(name)", "uses: [Enact]", "procedures:", "  main:", "    access: public", "    failing: anything"]
        let body = statements.contains { statement in statement.value != nil }
            ? ["    body:"] + statements.flatMap { statement in statement.lines(indent: "      ") }
            : statements.flatMap { statement in statement.lines(indent: "    ") } + ["    body: []"]
        
        return (head + body).joined(separator: "\n") + "\n"
    }
    
    // MARK: - Initializer
    // Named as the file it is written to, in upper camel case.
    init(for file: URL) {
        let words = file.deletingPathExtension().lastPathComponent
            .split { character in !(character.isASCII && (character.isLetter || character.isNumber)) }
        let name = words.map { word in word.prefix(1).uppercased() + word.dropFirst() }.joined()
        
        self.name = name.first?.isLetter == true ? name : "Draft"
    }
    
    // MARK: - Public
    // Writes what an operation did. A press is named by the look before it
    // and by what element_at read at its point, and one that may lead on to
    // another screen leaves a wait open until the next look settles it.
    mutating func write(_ operation: DraftOperation, seen: ObservedScreen?, hit: ObservedElement?) {
        defer {
            if operation.leadsOn { wait = .open(before: seen) }
        }
        
        let answered = seen.flatMap { seen in hit.flatMap { hit in Self.fills(hit, seen.screen) ? nil : hit } }
        let pressed = seen.flatMap { seen in answered.flatMap { hit in PressedElement(hit, in: seen) } }
        
        switch operation {
        case let .tap(point):
            if let pressed {
                append(.call("tap", [DraftNode.Entry("on", .ref(waited(for: pressed)))]))
            } else {
                pressPoint(point, hit: answered, on: seen)
            }
        
        case let .longPress(point, duration):
            if let pressed {
                append(.call(
                    "long_press",
                    [DraftNode.Entry("on", .ref(waited(for: pressed))), DraftNode.Entry("duration", .number(duration))]
                ))
            } else {
                statements.append(DraftStatement(
                    comment: "no verb holds a press on what no look names: long-press at \(spelled(point)) for \(duration)s"
                ))
            }
        
        case let .stroke(verb, stroke):
            guard let screen = seen?.screen else {
                statements.append(DraftStatement(
                    comment: "no look read the screen to give the stroke as fractions of: \(verb) from \(spelled(stroke.start)) to \(spelled(stroke.end))"
                ))
                
                return
            }
            
            if let pressed {
                append(.call("wait_for", [DraftNode.Entry("where", pressed.catch.where)]), comments: comments(on: pressed))
            }
            
            append(.call(
                verb,
                [
                    DraftNode.Entry("from", .fraction(screen.fraction(of: stroke.start))),
                    DraftNode.Entry("to", .fraction(screen.fraction(of: stroke.end))),
                    DraftNode.Entry("duration", .number(stroke.duration))
                ]
            ))
        
        case let .swipe(point, direction, duration):
            guard let screen = seen?.screen else {
                statements.append(DraftStatement(
                    comment: "no look read the screen to give the swipe as fractions of: swipe \(direction.rawValue) from \(spelled(point))"
                ))
                
                return
            }
            
            if let pressed {
                append(.call("wait_for", [DraftNode.Entry("where", pressed.catch.where)]), comments: comments(on: pressed))
            }
            
            let start = screen.fraction(of: point)
            
            append(.call(
                "swipe_between",
                [
                    DraftNode.Entry("from", .fraction(start)),
                    DraftNode.Entry("to", .fraction(direction.end(from: start))),
                    DraftNode.Entry("duration", .number(duration))
                ]
            ))
        
        case let .moveSlider(frame, to):
            if let pressed {
                append(.call(
                    "move_slider",
                    [DraftNode.Entry("on", .ref(waited(for: pressed))), DraftNode.Entry("value", .number(to))]
                ))
            } else {
                statements.append(DraftStatement(
                    comment: "no look names the slider at \(spelled(frame.center)), so it is not moved to \(to)"
                ))
            }
        
        case let .call(call):
            append(call)
        
        case let .comment(comment):
            statements.append(DraftStatement(comment: comment))
        }
    }
    
    // Settles an open wait by the look after the press, nil where it failed,
    // before anything else is written. Nothing where no wait is open.
    mutating func settle(on seen: ObservedScreen?) {
        guard case let .open(before) = wait else { return }
        
        wait = .settled
        waitForScreen(before: before, after: seen)
    }
    
    // Closes an open wait with no screen to settle it by, as when the next input
    // was given before the screen the press led on to was read. Nothing where no
    // wait is open.
    mutating func leaveUnsettled() {
        guard case .open = wait else { return }
        
        wait = .settled
        statements.append(DraftStatement(comment: "the next input came before the screen after this was read; wait here for what it showed"))
    }
    
    // Writes the wait for the screen a press led on to, by what it newly
    // shows.
    mutating func waitForScreen(before: ObservedScreen?, after: ObservedScreen?) {
        guard let before,
            let after,
            let awaited = ScreenChange(from: before, to: after).awaited
        else {
            statements.append(DraftStatement(comment: "the screen after this showed nothing new to wait for"))
            
            return
        }
        
        append(.call(
            "wait_for",
            [DraftNode.Entry("where", ElementCatch.shown(awaited.snapshot.role, awaited.text).where)]
        ))
    }
    
    // MARK: - Private
    private mutating func append(_ value: DraftNode, named name: String? = nil, comments: [String] = []) {
        statements.append(DraftStatement(value, named: name, comments: comments))
    }
    
    // A wait for what a press lands on, and the name it is held by.
    private mutating func waited(for pressed: PressedElement) -> String {
        let name = unique(name(of: pressed.catch, role: pressed.element.snapshot.role))
        
        append(.call("wait_for", [DraftNode.Entry("where", pressed.catch.where)]), named: name, comments: comments(on: pressed))
        
        return name
    }
    
    // A tap at a point no look names: checked by element_at's label where it
    // answers with one, and left to be confirmed where it does not.
    private mutating func pressPoint(_ point: Point, hit: ObservedElement?, on seen: ObservedScreen?) {
        guard let screen = seen?.screen else {
            statements.append(DraftStatement(comment: "no look read the screen to give the tap as a fraction of: tap at \(spelled(point))"))
            
            return
        }
        
        let at = DraftNode.fraction(screen.fraction(of: point))
        let tap = DraftNode.call("tap_point", [DraftNode.Entry("at", at)])
        
        guard let hit else {
            append(tap, comments: ["nothing answers a press here; confirm what is there"])
            
            return
        }
        
        let checked: (field: String, text: String)? = if let label = hit.snapshot.label, !label.isEmpty {
            (field: "label", text: label)
        } else if let id = hit.snapshot.id, !id.isEmpty {
            (field: "id", text: id)
        } else {
            nil
        }
        
        guard let checked else {
            append(tap, comments: ["element_at finds an element of role \(EnactVocabulary.role.caseName(of: hit.snapshot.role)) here with nothing to check it by; confirm what is there"])
            
            return
        }
        
        let hits = DraftNode.call("element_at", [DraftNode.Entry("at", at)])
        
        append(
            .call(
                "repeat",
                [
                    DraftNode.Entry("timeout", .number(10)),
                    DraftNode.Entry("debounce", .number(0.5)),
                    DraftNode.Entry("body", .closure(returns: "Enact.Snapshot?", result: hits)),
                    DraftNode.Entry(
                        "until",
                        .closure(parameter: "hit", type: "Enact.Snapshot?", result: .is(.ref("hit?.\(checked.field)"), .quoted(checked.text)))
                    )
                ]
            ),
            comments: ["no look names what is pressed here, so element_at checks it"]
        )
        append(tap)
    }
    
    // Which element a catch that holds of more than one means.
    private func comments(on pressed: PressedElement) -> [String] {
        guard pressed.matched > 1 else { return [] }
        
        let inside = pressed.ancestor.map { ancestor in
            if let label = ancestor.snapshot.label, !label.isEmpty { return ", inside \"\(label)\"" }
            
            return ", inside #\(ancestor.snapshot.id ?? "")"
        } ?? ""
        
        return ["this catches \(pressed.matched) elements; the one pressed is the \(ordinal(pressed.place + 1)) in reading order\(inside)"]
    }
    
    // A name made of the first words of what an element is caught by and its
    // role, in lower camel case.
    private func name(of caught: ElementCatch, role: Role) -> String {
        let text = switch caught {
        case let .label(text), let .shown(_, text):
            text
        
        case let .id(id):
            String(id.split(separator: ".").last ?? "")
        }
        let words = text
            .split { character in !(character.isASCII && (character.isLetter || character.isNumber)) }
            .prefix(3)
            .map { word in word.prefix(1).uppercased() + word.dropFirst().lowercased() }
        let role = EnactVocabulary.role.caseName(of: role)
        let name = (words + [role.prefix(1).uppercased() + role.dropFirst()]).joined()
        
        guard name.first?.isLetter == true else { return role + words.joined() }
        
        return name.prefix(1).lowercased() + name.dropFirst()
    }
    
    private mutating func unique(_ name: String) -> String {
        var free = name
        var count = 1
        
        while names.contains(free) {
            count += 1
            free = "\(name)\(count)"
        }
        
        names.insert(free)
        
        return free
    }
    
    private func ordinal(_ place: Int) -> String {
        let suffix = switch (place % 10, place % 100) {
        case (_, 11...13):
            "th"
        
        case (1, _):
            "st"
        
        case (2, _):
            "nd"
        
        case (3, _):
            "rd"
        
        default:
            "th"
        }
        
        return "\(place)\(suffix)"
    }
    
    private func spelled(_ point: Point) -> String {
        "\(point.x),\(point.y)"
    }
    
    // An element as large as the screen, such as an app's root, is what
    // any press lands on, so it names none.
    private static func fills(_ element: ObservedElement, _ screen: Screen) -> Bool {
        let frame = element.snapshot.frame
        
        return frame.x <= 0 && frame.y <= 0 && frame.x + frame.width >= screen.width && frame.y + frame.height >= screen.height
    }
}

//
//  SoftwareKeyboard.swift
//  Digit
//
//  Created by JSilver on 11/9/26.
//

import FBSimulatorAX
import FBSimulatorControl
import Foundation

// The keyboard on screen, typing a character by tapping the key labeled with it, on
// whichever keyboards the device has. Its keys are found by their labels in the
// accessibility tree, and the layer that has one by tapping the control keys.
struct SoftwareKeyboard {
    // MARK: - Property
    // The keys come up a moment after a field is tapped. With the hardware keyboard
    // connected they do not come up.
    private static let settleTimeout: Duration = .milliseconds(1500)
    // A tap on a control key redraws the keys a moment after it lands, and a tap the
    // keys have not answered by then is tapped again. A control key tapped sooner than
    // the double tap interval after another is passed over, or taken with it as a double
    // tap, which locks shift, so it waits the interval out. Next keyboard takes a tap
    // only a moment after any key's; one sooner lands on a key beside it, so it is
    // tapped after a pause.
    private static let redrawTimeout: Duration = .seconds(3)
    private static let retapInterval: Duration = .milliseconds(600)
    private static let doubleTapInterval: Duration = .milliseconds(500)
    private static let nextKeyboardPause: Duration = .milliseconds(500)
    // A read can come before the app has taken the tap sent just before it. It is
    // current once it shows the text the tap typed.
    private static let typedTimeout: Duration = .seconds(1)
    private static let pollInterval: Duration = .milliseconds(100)
    
    private let simulator: Simulator
    private let hid: SimulatorHID
    private let inputMethod: any InputMethod = Dubeolsik()
    
    // MARK: - Initializer
    init(simulator: Simulator, hid: SimulatorHID) {
        self.simulator = simulator
        self.hid = hid
    }
    
    // MARK: - Public
    // The text goes to whatever the keys on the screen type into.
    func type(_ text: String) async throws {
        let spellings = try spellings(of: text)
        
        guard let shown = try await waitForKeys() else { throw DigitError.noSoftwareKeyboard }
        
        try await type(spellings, from: shown)
    }
    
    // MARK: - Private
    private func spellings(of text: String) throws -> [Spelling] {
        try zip([nil] + text.map(Optional.some), text).map { previous, character in
            try Spelling(character, after: previous, inputMethod: inputMethod)
        }
    }
    
    // Every key the text needs is found before the first is tapped, and the keyboard is
    // left as it was found.
    private func type(_ spellings: [Spelling], from screen: TypingScreen) async throws {
        var graph = KeyboardGraph()
        var screen = screen
        let start = screen.keyplane.state.nextKeyboard
        
        // When a control key was last tapped, until another key is.
        var controlTapped: ContinuousClock.Instant?
        
        graph.visit(screen.keyplane.state)
        
        for case let .keys(keys, character, _) in spellings {
            for key in keys where !graph.contains(key) {
                guard try await walk(&screen, in: &graph, after: &controlTapped, to: key) else {
                    try await switchKeyboard(&screen, after: &controlTapped) { keyboard in keyboard == start }
                    
                    throw DigitError.untypeableCharacter(character, keyboards: graph.keyboards)
                }
            }
        }
        
        var check = FieldCheck.undecided
        
        for spelling in spellings {
            switch spelling {
            case let .keys(keys, character, _):
                for key in keys {
                    // Every key was found before typing began, so one out of reach now is
                    // the keyboard's doing, such as a return that took it away.
                    guard try await walk(&screen, in: &graph, after: &controlTapped, to: key) else {
                        throw DigitError.unreadableOutput(
                            of: "software keyboard",
                            reason: "it no longer reaches a key for '\(character)' after typing began"
                        )
                    }
                    
                    let tapped = try await tap(key, on: screen, waiting: check != .unchecked)
                    let typed = tapped.fieldValues != screen.fieldValues
                    
                    switch (check, typed) {
                    case (.checked, false):
                        throw DigitError.unreadableOutput(
                            of: "software keyboard",
                            reason: "tapping \(key) typed nothing within \(Self.typedTimeout)"
                        )
                    
                    case (.undecided, _):
                        check = typed ? .checked : .unchecked
                    
                    default:
                        break
                    }
                    
                    controlTapped = nil
                    screen = tapped
                }
            
            case let .press(code):
                try await hid.send(event: .shortKeyPress(code), logger: simulator.logger)
                
                controlTapped = nil
                screen = try await read(after: screen, waiting: check != .unchecked)
            }
        }
        
        // Switching keyboards commits the syllable still composing, which a jamo typed
        // next would otherwise join. A device with one keyboard has no key to switch with.
        if case .keys(_, _, composed: true) = spellings.last,
            screen.keyplane.state.nextKeyboard == start,
            screen.keyplane.state.keys.contains(.nextKeyboard) {
            try await switchKeyboard(&screen, after: &controlTapped) { keyboard in keyboard != start }
        }
        
        try await switchKeyboard(&screen, after: &controlTapped) { keyboard in keyboard == start }
    }
    
    // The control on a layer that a key is likeliest behind, tried first to find it:
    // Next keyboard for a key seen on other keyboards only, or for a letter no case of
    // which is among the letters seen; else the number key from a layer of letters to
    // one without, and back, and shift between two layers of the same kind.
    private func preferredControl(toFind key: SoftwareKey, in graph: KeyboardGraph) -> (KeyboardState) -> SoftwareKey? {
        let having = graph.keyboards(having: key)
        let isLetter = Self.isLetter(key)
        let isForeign = having.isEmpty && isLetter && graph.contains(where: Self.isLetter) && !Self.cases(of: key)
            .contains(where: graph.contains)
        
        return { state in
            if isForeign || !(having.isEmpty || having.contains(state.nextKeyboard)) { return .nextKeyboard }
            
            return state.keys.contains(where: Self.isLetter) == isLetter ? .shift : .more
        }
    }
    
    private static func cases(of key: SoftwareKey) -> [SoftwareKey] {
        guard case let .character(character) = key else { return [] }
        
        return [character.lowercased(), character.uppercased()].compactMap { spelled in
            spelled.count == 1 ? spelled.first.map(SoftwareKey.character) : nil
        }
    }
    
    private static func isLetter(_ key: SoftwareKey) -> Bool {
        guard case let .character(character) = key else { return false }
        
        return character.isLetter
    }
    
    // Taps control keys until the keys are a layer with `key`, false when no tap left can
    // get there.
    private func walk(
        _ screen: inout TypingScreen,
        in graph: inout KeyboardGraph,
        after controlTapped: inout ContinuousClock.Instant?,
        to key: SoftwareKey
    ) async throws -> Bool {
        let reached = { (state: KeyboardState) in state.keys.contains(key) }
        
        graph.visit(screen.keyplane.state)
        
        while !reached(screen.keyplane.state) {
            guard let control = graph.step(
                from: screen.keyplane.state,
                toward: reached,
                preferring: preferredControl(toFind: key, in: graph)
            ) else {
                return false
            }
            
            let tapped = try await press(control, on: screen, after: &controlTapped)
            
            graph.record(control, from: screen.keyplane.state, to: tapped.keyplane.state)
            screen = tapped
        }
        
        return true
    }
    
    // Only Next keyboard changes the keyboard, so the way to one is along it alone, and
    // a keyboard named twice means the round passed without reaching it.
    private func switchKeyboard(
        _ screen: inout TypingScreen,
        after controlTapped: inout ContinuousClock.Instant?,
        until reached: (String?) -> Bool
    ) async throws {
        var named: Set<String?> = []
        
        while !reached(screen.keyplane.state.nextKeyboard) {
            guard named.insert(screen.keyplane.state.nextKeyboard).inserted else {
                throw DigitError.unreadableOutput(
                    of: "software keyboard",
                    reason: "Next keyboard does not lead to the keyboard it was on"
                )
            }
            
            screen = try await press(.nextKeyboard, on: screen, after: &controlTapped)
        }
    }
    
    // The keys can show before they take taps, while they slide in, and a tap then can
    // be lost. They are up once two reads in a row show them in the same place. Nil when
    // they do not come up in time; keys that show by then are given until they settle.
    private func waitForKeys() async throws -> TypingScreen? {
        let start = ContinuousClock.now
        var previous: Keyplane?
        
        while true {
            let screen = try await read()
            let shown = !screen.keyplane.state.keys.isEmpty
            
            if shown, screen.keyplane == previous { return screen }
            
            guard ContinuousClock.now < start + (shown ? Self.redrawTimeout : Self.settleTimeout) else {
                return nil
            }
            
            previous = screen.keyplane
            
            try await Task.sleep(for: Self.pollInterval)
        }
    }
    
    // A read can come before the app has taken the tap, so it is read again until a field
    // changes, when that is waited for.
    private func tap(_ key: SoftwareKey, on screen: TypingScreen, waiting: Bool) async throws -> TypingScreen {
        try await tap(at: point(of: key, on: screen))
        
        return try await read(after: screen, waiting: waiting)
    }
    
    // A control key changes the keys, which tells the tap landed: Next keyboard the
    // keyboard it names, the others the layer. `controlTapped` is when a control key was
    // last tapped.
    private func press(
        _ control: SoftwareKey,
        on screen: TypingScreen,
        after controlTapped: inout ContinuousClock.Instant?
    ) async throws -> TypingScreen {
        let point = try point(of: control, on: screen)
        let landed: (KeyboardState) -> Bool = control == .nextKeyboard
            ? { state in state.nextKeyboard != screen.keyplane.state.nextKeyboard }
            : { state in state != screen.keyplane.state }
        
        if control == .nextKeyboard { try await Task.sleep(for: Self.nextKeyboardPause) }
        
        let deadline = ContinuousClock.now + Self.redrawTimeout
        var retap = ContinuousClock.now
        
        while true {
            if ContinuousClock.now >= retap {
                if let controlTapped {
                    try await Task.sleep(until: controlTapped + Self.doubleTapInterval)
                }
                
                try await tap(at: point)
                
                controlTapped = ContinuousClock.now
                retap = ContinuousClock.now + Self.retapInterval
            }
            
            let read = try await read()
            
            if landed(read.keyplane.state) { return read }
            
            guard ContinuousClock.now < deadline else {
                throw DigitError.unreadableOutput(
                    of: "software keyboard",
                    reason: "its keys did not change within \(Self.redrawTimeout) of tapping \(control)"
                )
            }
            
            try await Task.sleep(for: Self.pollInterval)
        }
    }
    
    // The first read on which a field differs from `screen`, or the last within the wait.
    private func read(after screen: TypingScreen, waiting: Bool) async throws -> TypingScreen {
        let deadline = ContinuousClock.now + Self.typedTimeout
        
        while true {
            let read = try await read()
            
            guard waiting, read.fieldValues == screen.fieldValues, ContinuousClock.now < deadline else {
                return read
            }
            
            try await Task.sleep(for: Self.pollInterval)
        }
    }
    
    // While the keys are redrawn, the keyboard shows Next keyboard alone for a moment,
    // so a read with keys but no character key is read again.
    private func read() async throws -> TypingScreen {
        let deadline = ContinuousClock.now + Self.redrawTimeout
        
        while true {
            let screen = try TypingScreen(try await AccessibilityReader(simulator: simulator).read(.frontmost))
            let keys = screen.keyplane.state.keys
            let isRedrawing = !keys.isEmpty && !keys.contains { key in
                guard case .character = key else { return false }
                
                return true
            }
            
            guard isRedrawing, ContinuousClock.now < deadline else { return screen }
            
            try await Task.sleep(for: Self.pollInterval)
        }
    }
    
    private func point(of key: SoftwareKey, on screen: TypingScreen) throws -> Point {
        guard let point = screen.keyplane.points[key] else {
            throw DigitError.unreadableOutput(of: "software keyboard", reason: "it shows no \(key) key")
        }
        
        return point
    }
    
    private func tap(at point: Point) async throws {
        try await hid.send(event: .tapAt(x: point.x, y: point.y), logger: simulator.logger)
    }
}


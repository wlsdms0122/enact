//
//  ScenarioDraftTests.swift
//  EnactCLITests
//
//  Created by JSilver on 11/10/26.
//

import Foundation
import Testing
@testable import Digit
@testable import Enact
@testable import EnactCLI
@testable import EnactWarp

@Suite("A draft names each press by what the screen showed under it, and waits for the screen it led on to")
struct ScenarioDraftTests {
    // MARK: - Property
    private let screen = try! Screen(width: 400, height: 800)
    
    // MARK: - Initializer
    // MARK: - Test
    @Test("a press on an element the look has waits for it by its label and taps what the wait returns")
    func aPressOnALabelledElementIsCaughtByItsLabel() throws {
        // Given
        let general = observed(label: "General", id: "settings.general", role: .button, y: 400, at: [1])
        var sut = ScenarioDraft(for: URL(fileURLWithPath: "/tmp/settings-walk.yaml"))
        
        // When
        sut.write(.tap(general.snapshot.frame.center), seen: look([general]), hit: hit(general))
        
        // Then
        #expect(sut.text == """
            name: SettingsWalk
            uses: [Enact]
            procedures:
              main:
                access: public
                failing: anything
                body:
                  - let: generalButton
                    value: { call: { procedure: wait_for, arguments: { where: { closure: { parameters: [ { one: Enact.Snapshot } ], result: { of: { ref: one.label }, is: "General" } } } } } }
                  - value: { call: { procedure: tap, arguments: { on: { ref: generalButton } } } }
            
            """)
    }
    
    @Test("an element with no label is caught by its identifier, and one with neither by its role and the text it shows")
    func anUnlabelledElementFallsBack() {
        // Given
        let close = observed(id: "close", role: .button, y: 100, at: [0])
        let search = observed(value: "Search", role: .field, y: 700, at: [1])
        let blank = observed(role: .image, y: 400, at: [2])
        let seen = look([close, search, blank])
        var sut = ScenarioDraft(for: URL(fileURLWithPath: "/tmp/draft.yaml"))
        
        // When
        sut.write(.tap(close.snapshot.frame.center), seen: seen, hit: hit(close))
        sut.write(.tap(search.snapshot.frame.center), seen: seen, hit: hit(search))
        sut.write(.tap(blank.snapshot.frame.center), seen: seen, hit: hit(blank))
        
        // Then
        let text = sut.text
        
        #expect(text.contains("- let: closeButton"))
        #expect(text.contains("result: { of: { ref: one.id }, is: \"close\" }"))
        #expect(text.contains("- let: searchField"))
        #expect(text.contains("{ let: role, type: Enact.Role, value: { case: field } }"))
        #expect(text.contains("is: \"Search\""))
        #expect(text.contains("# element_at finds an element of role image here with nothing to check it by; confirm what is there"))
        #expect(text.contains("{ procedure: tap_point, arguments: { at: { struct: { x: 0.5, y: 0.513 } } } }"))
    }
    
    @Test("a press on what no look names checks element_at's label, and a press on nothing asks to confirm")
    func aPressOutsideTheLookIsAPoint() {
        // Given
        let pill = observed(label: "Pill", role: .button, y: 400, at: [])
        let root = Snapshot(
            Element(label: "App", role: .container, frame: Element.Frame(x: 0, y: 0, width: 400, height: 800)),
            at: []
        )
        let seen = look([observed(label: "Title", role: .heading, y: 100, at: [0])])
        var sut = ScenarioDraft(for: URL(fileURLWithPath: "/tmp/draft.yaml"))
        
        // When
        sut.write(.tap(Point(x: 200, y: 420)), seen: seen, hit: pill)
        sut.write(.tap(Point(x: 200, y: 20)), seen: seen, hit: ObservedElement(root, text: "App"))
        sut.write(.tap(Point(x: 200, y: 600)), seen: seen, hit: nil)
        
        // Then
        #expect(body(of: sut) == [
            "# no look names what is pressed here, so element_at checks it",
            "- value: { call: { procedure: repeat, arguments: { timeout: 10.0, debounce: 0.5, body: { closure: { returns: \"Enact.Snapshot?\", result: { call: { procedure: element_at, arguments: { at: { struct: { x: 0.5, y: 0.525 } } } } } } }, until: { closure: { parameters: [ { hit: \"Enact.Snapshot?\" } ], result: { of: { ref: \"hit?.label\" }, is: \"Pill\" } } } } } }",
            "- value: { call: { procedure: tap_point, arguments: { at: { struct: { x: 0.5, y: 0.525 } } } } }",
            "# nothing answers a press here; confirm what is there",
            "- value: { call: { procedure: tap_point, arguments: { at: { struct: { x: 0.5, y: 0.025 } } } } }",
            "# nothing answers a press here; confirm what is there",
            "- value: { call: { procedure: tap_point, arguments: { at: { struct: { x: 0.5, y: 0.75 } } } } }"
        ])
    }
    
    @Test("a catch more than one element answers to says which one was pressed and what it is inside")
    func aSharedCatchIsCommented() {
        // Given
        let first = observed(label: "Edit", role: .button, y: 100, at: [0])
        let list = observed(id: "list", role: .container, y: 500, at: [1])
        let second = observed(label: "Edit", role: .button, y: 500, at: [1, 0])
        var sut = ScenarioDraft(for: URL(fileURLWithPath: "/tmp/draft.yaml"))
        
        // When
        sut.write(.tap(second.snapshot.frame.center), seen: look([first, list, second]), hit: hit(second))
        sut.write(.tap(first.snapshot.frame.center), seen: look([first, list, second]), hit: hit(first))
        
        // Then
        let lines = body(of: sut)
        
        #expect(lines[0] == "# this catches 2 elements; the one pressed is the 2nd in reading order, inside #list")
        #expect(lines[1] == "- let: editButton")
        #expect(lines[4] == "# this catches 2 elements; the one pressed is the 1st in reading order")
        #expect(lines[5] == "- let: editButton2")
    }
    
    @Test("a label more than one element shows gives way to the identifier when that catches the pressed one alone")
    func aSharedLabelGivesWayToAnIdentifier() {
        // Given
        let root = observed(label: "Settings", role: .container, y: 300, at: [0])
        let back = observed(label: "Settings", id: "BackButton", role: .button, y: 80, at: [0, 0])
        var sut = ScenarioDraft(for: URL(fileURLWithPath: "/tmp/draft.yaml"))
        
        // When
        sut.write(.tap(back.snapshot.frame.center), seen: look([root, back]), hit: hit(back))
        
        // Then
        let lines = body(of: sut)
        
        #expect(lines[0] == "- let: backbuttonButton")
        #expect(lines[1].contains(#"{ of: { ref: one.id }, is: "BackButton" }"#))
    }
    
    @Test("where no catch holds of the pressed element alone, the first under which it is the first in reading order is used")
    func aCatchThatFindsThePressedOneFirstIsUsed() {
        // Given
        let note = observed(label: "Delete", role: .text, y: 100, at: [0])
        let pressed = observed(label: "Delete", role: .button, y: 300, at: [1])
        let other = observed(label: "Delete", role: .button, y: 500, at: [2])
        var sut = ScenarioDraft(for: URL(fileURLWithPath: "/tmp/draft.yaml"))
        
        // When
        sut.write(.tap(pressed.snapshot.frame.center), seen: look([note, pressed, other]), hit: hit(pressed))
        
        // Then
        let lines = body(of: sut)
        
        #expect(lines[0] == "# this catches 2 elements; the one pressed is the 1st in reading order")
        #expect(lines[1] == "- let: deleteButton")
        #expect(lines[2].contains("{ let: role, type: Enact.Role, value: { case: button } }"))
        #expect(lines[2].contains("is: \"Delete\""))
        #expect(!lines[2].contains("ref: one.label"))
    }
    
    @Test("the screen a press led on to is waited for by what it newly shows, a heading first, then a field or a button, then a text")
    func theNextScreenIsWaitedForByTier() {
        // Given
        let row = observed(label: "General", role: .button, y: 400, at: [0])
        let heading = observed(label: "General", role: .heading, y: 100, at: [0])
        let about = observed(label: "About", role: .button, y: 300, at: [1])
        let note = observed(label: "Manage your setup", role: .text, y: 200, at: [2])
        let before = look([row])
        
        // When
        let walk = [
            look([heading, about, note]),
            look([row, about, note]),
            look([row, note]),
            look([row])
        ].map { after in
            var sut = ScenarioDraft(for: URL(fileURLWithPath: "/tmp/draft.yaml"))
            
            sut.waitForScreen(before: before, after: after)
            
            return body(of: sut)
        }
        
        // Then
        #expect(walk[0][0].contains("value: { case: heading }") && walk[0][0].contains("is: \"General\""))
        #expect(walk[1][0].contains("value: { case: button }") && walk[1][0].contains("is: \"About\""))
        #expect(walk[2][0].contains("value: { case: text }") && walk[2][0].contains("is: \"Manage your setup\""))
        #expect(walk[3] == ["# the screen after this showed nothing new to wait for"])
    }
    
    @Test("within a tier the text the screen shows once wins, then the first in reading order")
    func aTieGoesToWhatIsShownOnce() {
        // Given
        let before = look([observed(label: "Back", role: .button, y: 50, at: [0])])
        let repeated = observed(label: "Wi-Fi", role: .heading, y: 100, at: [0])
        let echo = observed(label: "Wi-Fi", role: .text, y: 300, at: [1])
        let once = observed(label: "Networks", role: .heading, y: 200, at: [2])
        let later = observed(label: "Other", role: .heading, y: 400, at: [3])
        
        // When
        let picked = [look([repeated, echo, once, later]), look([once, later])].map { after in
            var sut = ScenarioDraft(for: URL(fileURLWithPath: "/tmp/draft.yaml"))
            
            sut.waitForScreen(before: before, after: after)
            
            return body(of: sut)[0]
        }
        
        // Then
        #expect(picked[0].contains("is: \"Networks\""))
        #expect(picked[1].contains("is: \"Networks\""))
    }
    
    @Test("the keyboard and the row of predicted words above it are never what a screen is waited for by")
    func theKeyboardIsLeftOut() {
        // Given
        let field = observed(value: "Search", role: .field, y: 100, at: [0])
        let typed = observed(value: "wi", role: .field, y: 100, at: [0])
        let predicted = observed(label: "With", role: .button, y: 570, at: [1])
        let key = observed(label: "q", role: .key, y: 590, at: [2])
        let hint = observed(label: "No results", role: .text, y: 300, at: [3])
        
        // When
        let drafts = [look([typed, predicted, key]), look([typed, predicted, key, hint])].map { after in
            var sut = ScenarioDraft(for: URL(fileURLWithPath: "/tmp/draft.yaml"))
            
            sut.waitForScreen(before: look([field]), after: after)
            
            return body(of: sut)[0]
        }
        
        // Then
        #expect(drafts[0].contains("value: { case: field }") && drafts[0].contains("is: \"wi\""))
        #expect(drafts[1].contains("value: { case: field }"))
        #expect(!drafts.contains { line in line.contains("With") || line.contains("{ case: key }") })
    }
    
    @Test("a press that may lead on to another screen leaves a wait the next look settles, before what comes after it")
    func aPressLeavesAWaitTheNextLookSettles() {
        // Given
        let general = observed(label: "General", role: .button, y: 400, at: [0])
        let heading = observed(label: "General", role: .heading, y: 100, at: [0])
        let typing = DraftOperation.call(.call("type_text", [DraftNode.Entry("text", .quoted("wifi"))]))
        var sut = ScenarioDraft(for: URL(fileURLWithPath: "/tmp/draft.yaml"))
        
        // When
        sut.write(.tap(general.snapshot.frame.center), seen: look([general]), hit: hit(general))
        
        let opened = sut.awaitsScreen
        
        sut.settle(on: look([heading]))
        
        let settled = sut.awaitsScreen
        
        sut.write(typing, seen: nil, hit: nil)
        
        // Then
        let lines = body(of: sut)
        
        #expect(opened)
        #expect(!settled)
        #expect(!sut.awaitsScreen)
        #expect(lines.count == 5)
        #expect(lines[0] == "- let: generalButton")
        #expect(lines[2].contains("procedure: tap,"))
        #expect(lines[3].contains("value: { case: heading }") && lines[3].contains("is: \"General\""))
        #expect(lines[4].contains("procedure: type_text"))
    }
    
    @Test("an open wait is settled by the look before a line even where that line then fails, so nothing is left to settle at the end")
    func aWaitIsSettledBeforeAFailedLine() {
        // Given
        let general = observed(label: "General", role: .button, y: 400, at: [0])
        let heading = observed(label: "General", role: .heading, y: 100, at: [0])
        var sut = ScenarioDraft(for: URL(fileURLWithPath: "/tmp/draft.yaml"))
        
        sut.write(.tap(general.snapshot.frame.center), seen: look([general]), hit: hit(general))
        
        // When
        // The look before the next line settles the wait, and the line fails,
        // so nothing is written for it.
        sut.settle(on: look([heading]))
        
        let written = body(of: sut)
        
        // The end of input finds no wait open.
        sut.settle(on: look([general]))
        
        // Then
        #expect(!sut.awaitsScreen)
        #expect(written.count == 4)
        #expect(written[3].contains("value: { case: heading }"))
        #expect(body(of: sut) == written)
    }
    
    @Test("a wait is settled at the end of input, with a comment where that look failed, and what leads on nowhere opens none")
    func aWaitIsSettledAtTheEnd() {
        // Given
        let general = observed(label: "General", role: .button, y: 400, at: [0])
        let slider = observed(label: "Brightness", role: .slider, y: 600, at: [1])
        let seen = look([general, slider])
        var sut = ScenarioDraft(for: URL(fileURLWithPath: "/tmp/draft.yaml"))
        
        // When
        sut.write(.moveSlider(slider.snapshot.frame, to: 0.5), seen: seen, hit: hit(slider))
        
        let afterSlider = sut.awaitsScreen
        
        sut.write(.tap(general.snapshot.frame.center), seen: seen, hit: hit(general))
        sut.settle(on: nil)
        
        // Then
        let lines = body(of: sut)
        
        #expect(!afterSlider)
        #expect(!sut.awaitsScreen)
        #expect(lines.last == "# the screen after this showed nothing new to wait for")
        #expect(lines.filter { line in line.hasPrefix("#") }.count == 1)
    }
    
    @Test("a draft of a walk builds as a scenario")
    func aDraftBuilds() async throws {
        // Given
        let general = observed(label: "General", role: .button, y: 400, at: [0])
        let search = observed(value: "Search", role: .field, y: 700, at: [1])
        let heading = observed(label: "General", role: .heading, y: 100, at: [0])
        var sut = ScenarioDraft(for: URL(fileURLWithPath: "/tmp/settings-walk.yaml"))
        
        sut.write(.call(.call("launch_app", [DraftNode.Entry("bundle_id", .quoted("com.apple.Preferences"))])), seen: nil, hit: nil)
        sut.write(.tap(general.snapshot.frame.center), seen: look([general, search]), hit: hit(general))
        sut.settle(on: look([heading]))
        sut.write(.tap(search.snapshot.frame.center), seen: look([general, search]), hit: hit(search))
        sut.settle(on: look([general]))
        sut.write(.tap(Point(x: 10, y: 10)), seen: look([general]), hit: nil)
        sut.settle(on: look([heading]))
        sut.write(.tap(Point(x: 200, y: 420)), seen: look([heading]), hit: hit(general))
        sut.settle(on: nil)
        sut.write(.call(.call("type_text", [DraftNode.Entry("text", .quoted("wifi \"5G\""))])), seen: nil, hit: nil)
        sut.write(.comment("no verb does this: set-orientation landscape-left"), seen: nil, hit: nil)
        sut.write(.swipe(general.snapshot.frame.center, direction: "up", duration: 0.3), seen: look([general]), hit: hit(general))
        sut.settle(on: nil)
        var input = RecordedInput()
        
        for operation in [.key(InputEvent.Key(key: "c", modifiers: [.command])), .button(.home)].flatMap({ event in input.written(event, keys: []) }) {
            sut.write(operation, seen: nil, hit: nil)
        }
        
        // When
        let scenario = try await Engine().check(
            "SettingsWalk",
            store: PinnedStore(file: "-", text: sut.text, rest: SearchPathStore(roots: []))
        )
        
        // Then
        #expect(scenario.entry != nil)
    }
    
    @Test("a recorded swipe waits for what it began on and swipes the screen in its direction")
    func aRecordedSwipe() {
        // Given
        let general = observed(label: "General", role: .button, y: 400, at: [0])
        var sut = ScenarioDraft(for: URL(fileURLWithPath: "/tmp/draft.yaml"))
        
        // When
        sut.write(.swipe(general.snapshot.frame.center, direction: "up", duration: 0.3), seen: look([general]), hit: hit(general))
        
        // Then
        let lines = body(of: sut)
        
        #expect(sut.awaitsScreen)
        #expect(lines.last == "- value: { call: { procedure: swipe, arguments: { direction: { case: up }, duration: 0.3 } } }")
        #expect(lines.first?.contains(#"is: "General""#) == true)
    }
    
    // MARK: - Private
    private func observed(
        label: String? = nil,
        id: String? = nil,
        value: String? = nil,
        role: Role,
        y: Double,
        at indexPath: [Int]
    ) -> ObservedElement {
        let snapshot = Snapshot(
            Element(id: id, label: label, value: value, role: role, frame: Element.Frame(x: 100, y: y, width: 200, height: 20)),
            at: indexPath
        )
        let text = [.field, .secureField].contains(role) ? value ?? "" : label ?? ""
        
        return ObservedElement(snapshot, text: text)
    }
    
    // What element_at reads of an element of a look: the same, standing in
    // no look.
    private func hit(_ element: ObservedElement) -> ObservedElement {
        ObservedElement(
            Snapshot(
                id: element.snapshot.id,
                label: element.snapshot.label,
                value: element.snapshot.value,
                role: element.snapshot.role,
                enabled: element.snapshot.enabled,
                actions: element.snapshot.actions,
                frame: element.snapshot.frame,
                track: element.snapshot.track,
                indexPath: []
            ),
            text: element.text
        )
    }
    
    private func look(_ elements: [ObservedElement]) -> ObservedScreen {
        ObservedScreen(screen, elements: elements)
    }
    
    // The lines of the draft's main body and the comments in it.
    private func body(of draft: ScenarioDraft) -> [String] {
        draft.text
            .split(separator: "\n")
            .drop { line in line != "    failing: anything" }
            .dropFirst()
            .filter { line in !line.hasPrefix("    body:") }
            .map { line in line.trimmingCharacters(in: .whitespaces) }
    }
}

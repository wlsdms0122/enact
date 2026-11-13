//
//  Draft.swift
//  EnactCLI
//
//  Created by JSilver on 11/10/26.
//

import ArgumentParser
import Digit
import DigitCLI
import Enact
import Foundation

struct Draft: AsyncParsableCommand {
    // MARK: - Property
    static let configuration = CommandConfiguration(
        commandName: "draft",
        abstract: "Write what each line of standard input does to a device as a scenario draft.",
        discussion: """
            The lines and their answers are a session's, as enact device session \
            reads and answers them. Each line that does something to the device \
            is also written to --output as a statement of the draft's main, in \
            the order the lines came, by the verb that does the same. A line \
            that only reads the device, a line that is refused, and a line that \
            fails are not written. What no verb does is written as a comment. \
            The file is written again after every line, so it is a scenario at \
            any moment, named as the file is in upper camel case.
            
            A press (tap, long-press, the start of a swipe or a drag) is named \
            by what the screen shows under it, read with the library's look and \
            element_at before it is done: a wait_for that catches the element \
            by its label, else its identifier, else its role and the text it \
            shows, and the verb on what that wait returns. What no look names \
            is pressed as a point of the screen, checked by element_at where it \
            answers, and left with a comment to confirm what is there where it \
            does not.
            
            The look taken before the next line, or one more at the end of \
            standard input, is the screen a press led on to. What it newly \
            shows, a heading first, then a field or a button, then a text, and \
            never the keyboard, is written as a wait_for after the press. Right \
            after an app is launched its elements may not be read yet, and a \
            press then gets a comment in place of a wait.
            
            The draft is for a person to edit: what is pressed and what is \
            waited for are what one run of the lines saw.
            
            With --record-input no line is read: what is written is the input \
            the device is given, a person's taps in the simulator's window as \
            much as anything else's, as enact device record-input reads it, \
            until Ctrl-C. A swipe is written by its direction, the software \
            keyboard's keys tapped in a row as one type_text, and a press is \
            named by the look taken after the input before it, where the \
            application showed the same element there when it was pressed.
            """
    )
    
    @OptionGroup var target: DeviceOption
    
    @Option(name: .customLong("output"), help: "The scenario file the draft is written to.")
    var output: String
    
    @Flag(
        name: .customLong("record-input"),
        help: "Write the input the device is given, by a person or anything else, until stopped, instead of reading lines."
    )
    var recordsInput = false
    
    // MARK: - Initializer
    // MARK: - Public
    func run() async throws {
        let device = try target.device()
        let observer = try await ScreenObserver(device: device)
        let file = URL(fileURLWithPath: output)
        
        if recordsInput {
            try await draftInput(of: device, seenBy: observer, to: file)
        } else {
            try await draftLines(on: device, seenBy: observer, to: file)
        }
    }
    
    // MARK: - Private
    private func draftLines(on device: Device, seenBy observer: ScreenObserver, to file: URL) async throws {
        let interpreter = SessionInterpreter(udid: target.udid)
        var draft = ScenarioDraft(for: file)
        
        save(draft, to: file)
        
        try await StandardInput().forEachLine { line in
            let command: any DeviceCommand
            let operation: DraftOperation?
            
            do throws(SessionFailure) {
                guard let read = try interpreter.command(line) else { return }
                
                command = read
            } catch {
                SessionReply.error(error).write()
                
                return
            }
            
            do {
                operation = try DraftOperation(command, line: String(decoding: line, as: UTF8.self))
            } catch {
                SessionReply.error(SessionFailure(performing: error)).write()
                
                return
            }
            
            guard let operation else {
                await interpreter.perform(command, on: device).write()
                
                return
            }
            
            let point = operation.point
            let seen = draft.awaitsScreen || point != nil ? try? await observer.look() : nil
            
            draft.settle(on: seen)
            
            let hit: ObservedElement? = if let point, let seen { try? await observer.element(at: point, on: seen.screen) } else { nil }
            let reply = await interpreter.perform(command, on: device)
            
            reply.write()
            
            if case .result = reply { draft.write(operation, seen: seen, hit: hit) }
            
            save(draft, to: file)
        }
        
        if draft.awaitsScreen {
            draft.settle(on: try? await observer.look())
            save(draft, to: file)
        }
    }
    
    // The input comes after it was given, so a press is named by the look taken
    // after the input before it, which is also the screen that input led on to.
    // The keys typed on the software keyboard in a row are written as one text.
    private func draftInput(of device: Device, seenBy observer: ScreenObserver, to file: URL) async throws {
        var draft = ScenarioDraft(for: file)
        var input = RecordedInput()
        let (events, received) = AsyncStream<InputEvent>.makeStream()
        let signals = SignalWaiter([SIGINT, SIGTERM])
        defer { signals.disarm() }
        
        save(draft, to: file)
        
        // Input given while the first look is taken is held until it is read.
        let recording = try await device.run(RecordInputOperator { event in received.yield(event) })
        var seen = try? await observer.look()
        
        FileHandle.standardError.write(Data("enact: recording the input to \(output); Ctrl-C ends it\n".utf8))
        
        let stopping = Task {
            await signals.wait()
            received.finish()
        }
        
        for await event in events {
            // The screen an input was given on is the one the input before led to,
            // so the wait for it goes before anything the input writes.
            draft.settle(on: seen)
            
            for operation in input.written(event, keys: seen?.keys ?? []) {
                draft.write(operation, seen: seen, hit: seen?.element(pressedBy: event))
            }
            
            save(draft, to: file)
            
            if case .gesture = event { seen = await Self.settledLook(by: observer) }
        }
        
        for operation in input.remaining() {
            draft.write(operation, seen: nil, hit: nil)
        }
        
        draft.settle(on: seen)
        save(draft, to: file)
        stopping.cancel()
        try await recording.stop()
    }
    
    // A look taken again until two in a row agree, so a screen still moving after
    // the input, as a list scrolling on, is read where it comes to rest.
    private static func settledLook(by observer: ScreenObserver) async -> ObservedScreen? {
        var last = try? await observer.look()
        
        for _ in 0..<5 {
            try? await Task.sleep(for: .milliseconds(300))
            
            let next = try? await observer.look()
            
            if next == last { break }
            
            last = next
        }
        
        return last
    }
    
    private func save(_ draft: ScenarioDraft, to file: URL) {
        do {
            try draft.text.write(to: file, atomically: true, encoding: .utf8)
        } catch {
            FileHandle.standardError.write(Data("enact: writing the draft to \(output): \(error)\n".utf8))
            Foundation.exit(EXIT_FAILURE)
        }
    }
}

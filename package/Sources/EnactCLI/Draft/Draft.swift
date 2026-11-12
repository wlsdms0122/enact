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
            """
    )
    
    @OptionGroup var target: DeviceOption
    
    @Option(name: .customLong("output"), help: "The scenario file the draft is written to.")
    var output: String
    
    // MARK: - Initializer
    // MARK: - Public
    func run() async throws {
        let device = try target.device()
        let interpreter = SessionInterpreter(udid: target.udid)
        let observer = try await ScreenObserver(device: device)
        let file = URL(fileURLWithPath: output)
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
    
    // MARK: - Private
    private func save(_ draft: ScenarioDraft, to file: URL) {
        do {
            try draft.text.write(to: file, atomically: true, encoding: .utf8)
        } catch {
            FileHandle.standardError.write(Data("enact: writing the draft to \(output): \(error)\n".utf8))
            Foundation.exit(EXIT_FAILURE)
        }
    }
}

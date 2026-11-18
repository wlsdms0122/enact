//
//  Session.swift
//  DigitCLI
//
//  Created by JSilver on 11/10/26.
//

import ArgumentParser
import Digit
import Foundation

struct Session: AsyncParsableCommand {
    // MARK: - Property
    static let configuration = CommandConfiguration(
        commandName: "session",
        abstract: "Do to one device what each line of standard input says, holding it open.",
        discussion: """
            Each line on standard input is a command as enact device spells it, \
            without --udid: tap --point 200,400, or describe-ui. It is done to \
            this device through the connection the session holds, so it does not \
            wait for a device to open. Words are split and quoted as a shell does. \
            Standard input is the session's lines, so a command that reads it \
            with - is refused, and its text is written on the line.
            
            Each line is answered by one line of JSON on standard output, in the \
            order the lines came: {"result": …} with what the command answers \
            (null for one that answers nothing), or {"error": {"kind": …, "detail": …}}. \
            The kind is argument_refused when the line is at fault (a line that \
            does not read, a command that is not there, an argument the command \
            or the device refuses) and device_refused otherwise, as a scenario's \
            steps name them. A blank line \
            is skipped and answered by nothing. The session ends with standard \
            input.
            
            The commands are the ones that do one thing to a device. Ones that \
            make, boot or end a device, and ones that run until stopped, are not.
            """
    )
    
    @OptionGroup var target: DeviceOption
    
    // MARK: - Initializer
    // MARK: - Public
    func run() async throws {
        let device = try target.device()
        let interpreter = SessionInterpreter(udid: target.udid)
        
        try await StandardInput().forEachLine { line in
            let reply: SessionReply
            
            do throws(SessionFailure) {
                guard let command = try interpreter.command(line) else { return }
                
                reply = await interpreter.perform(command, on: device)
            } catch {
                reply = .error(error)
            }
            
            reply.write()
        }
    }
    
    // MARK: - Private
}

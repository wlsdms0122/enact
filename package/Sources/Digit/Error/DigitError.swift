//
//  DigitError.swift
//  Digit
//
//  Created by JSilver on 8/16/26.
//

import Foundation

public enum DigitError: Error, CustomStringConvertible {
    case targetNotFound(udid: String)
    case untypeableCharacter(Character, keyboards: [String])
    case outOfRange(field: String, value: Int, allowed: ClosedRange<Int>)
    case outOfInterval(field: String, value: Double, allowed: ClosedRange<Double>)
    case nothingToDo(field: String)
    case tooFew(field: String, count: Int, least: Int)
    case malformedPayload(reason: String)
    case commandFailed(command: String, message: String)
    case noSuchOption(field: String, value: String, available: [String])
    case notPositive(field: String, value: Double)
    case deviceBusy(udid: String)
    case videoUnclosed(udid: String, marker: String, left: String)
    case recordingFailed(reason: String)
    case interrupted
    case ambiguousAlias(alias: String, candidates: [DeviceInfo])
    case unreadableOutput(of: String, reason: String)
    case noSuchContainer(bundleID: String, container: String)
    case joinedJamo(Character, after: Character)
    case noSoftwareKeyboard
    
    // MARK: - Property
    public var refusesArgument: Bool {
        switch self {
        case .untypeableCharacter, .joinedJamo, .outOfRange, .outOfInterval, .nothingToDo, .tooFew,
            .malformedPayload, .noSuchOption, .notPositive:
            return true
        
        case .targetNotFound, .commandFailed, .deviceBusy, .videoUnclosed, .recordingFailed,
            .interrupted, .ambiguousAlias, .unreadableOutput, .noSuchContainer, .noSoftwareKeyboard:
            return false
        }
    }
    
    public var description: String {
        switch self {
        case let .targetNotFound(udid):
            return "no such device: \(udid)"
        
        case let .untypeableCharacter(character, keyboards):
            return keyboards.isEmpty
                ? "'\(character)' is on no key of this device's keyboard"
                : "'\(character)' is on no key of this device's keyboards (\(keyboards.joined(separator: ", ")))"
        
        case let .notPositive(field, value):
            return "\(field) is \(value), which has to be more than zero"
        
        case let .nothingToDo(field):
            return "\(field) is empty, so this would change nothing"
        
        case let .tooFew(field, count, least):
            return "\(field) holds \(count), and needs at least \(least)"
        
        case let .malformedPayload(reason):
            return "payload is \(reason)"
        
        case let .commandFailed(command, message):
            return message.isEmpty ? "\(command) failed" : "\(command): \(message)"
        
        case let .noSuchOption(field, value, available):
            return "no \(field) named '\(value)'. This device has: "
                + available.joined(separator: ", ")
        
        case let .outOfRange(field, value, allowed):
            return "\(field) is \(value), outside \(allowed.lowerBound)…\(allowed.upperBound)"
        
        case let .outOfInterval(field, value, allowed):
            return "\(field) is \(value), outside \(allowed.lowerBound)…\(allowed.upperBound)"
        
        case let .deviceBusy(udid):
            return "\(udid) is in use"
        
        case let .videoUnclosed(udid, marker, left):
            return "\(udid): a video recording was attempted and its close never confirmed"
                + (left.isEmpty ? "" : " (\(left))")
                + ". It may have failed to start, or it may still be open in a process that "
                + "is gone and only a reboot can close. Check the device, then remove \(marker)"
        
        case let .recordingFailed(reason):
            return "the recorder failed: \(reason)"
        
        case .interrupted:
            return "interrupted"
        
        case let .ambiguousAlias(alias, candidates):
            let seen = candidates
                .map { "\($0.name)(\($0.udid.prefix(8)))" }
                .joined(separator: ", ")
            
            return candidates.isEmpty
                ? "no device is \(alias)"
                : "\(candidates.count) devices are \(alias). Name one: \(seen)"
        
        case let .unreadableOutput(what, reason):
            return "could not read \(what): \(reason)"
        
        case let .noSuchContainer(bundleID, container):
            return "\(bundleID) has no \(container) container on this device"
        
        case let .joinedJamo(jamo, previous):
            return "'\(previous)\(jamo)' cannot be typed as written: the Korean keyboard composes "
                + "'\(jamo)' into the '\(previous)' before it"
        
        case .noSoftwareKeyboard:
            return "no software keyboard is on the screen to type with. Tap the field to type "
                + "into first; a connected hardware keyboard keeps the software keyboard away, "
                + "and a device's first software keyboard stays behind its introduction until "
                + "Continue is tapped"
        }
    }
    
    // MARK: - Initializer
    // MARK: - Public
    // MARK: - Private
}

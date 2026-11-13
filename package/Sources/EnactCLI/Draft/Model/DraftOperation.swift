//
//  DraftOperation.swift
//  EnactCLI
//
//  Created by JSilver on 11/10/26.
//

import Digit
import DigitCLI
import EnactWarp
import Foundation

// What a line did to the device, as a draft writes it: a press, which the
// draft names by what it pressed, a call of the library verb that does the
// same, or a comment where no verb does.
enum DraftOperation {
    case tap(Point)
    case longPress(Point, duration: Double)
    case stroke(verb: String, Stroke)
    // A stroke known by where it began and the way it went, as a recorded swipe is.
    case swipe(Point, direction: String, duration: Double)
    case moveSlider(Element.Frame, to: Double)
    case call(DraftNode)
    case comment(String)
    
    // MARK: - Property
    // The commands that read the device and do nothing to it.
    private static let reads: Set<String> = Set(
        [
            Operation.describeUI,
            .describeScreen,
            .screenshot,
            .appState,
            .appAccessibility,
            .readPasteboard,
            .listApps,
            .appContainer,
            .appGroups
        ].map(\.rawValue) + ["capabilities"]
    )
    
    // Where it presses the screen.
    var point: Point? {
        switch self {
        case let .tap(point), let .longPress(point, _):
            point
        
        case let .stroke(_, stroke):
            stroke.start
        
        case let .swipe(point, _, _):
            point
        
        case let .moveSlider(frame, _):
            frame.center
        
        case .call, .comment:
            nil
        }
    }
    
    // Whether what it does may bring up another screen, which the draft then
    // waits for.
    var leadsOn: Bool {
        switch self {
        case .tap, .longPress, .stroke, .swipe:
            true
        
        case .moveSlider, .call, .comment:
            false
        }
    }
    
    // MARK: - Initializer
    // Nil for a command that only reads. The line is what the comment says
    // for a command no verb does.
    init?(_ command: any DeviceCommand, line: String) throws {
        guard let name = type(of: command).configuration.commandName, !Self.reads.contains(name) else { return nil }
        
        self = try Self.written(command) ?? .comment("no verb does this: \(line)")
    }
    
    // MARK: - Public
    // MARK: - Private
    private static func written(_ command: any DeviceCommand) throws -> DraftOperation? {
        switch command {
        case let tap as Tap:
            .tap(tap.point)
        
        case let press as LongPress:
            .longPress(press.point, duration: press.duration)
        
        case let swipe as Swipe:
            .stroke(verb: "swipe_between", try swipe.operator().stroke)
        
        case let drag as Drag:
            .stroke(verb: "drag", try drag.operator().stroke)
        
        case let slider as MoveSlider:
            .moveSlider(slider.frame, to: slider.to)
        
        case let typing as TypeText:
            .call(.call("type_text", [entry("text", .quoted(typing.text))]))
        
        case let press as PressKey:
            .call(.call(
                "press_key",
                [entry("key", .quoted(press.key))]
                    + (press.modifiers.isEmpty ? [] : [entry("modifiers", cases(press.modifiers, of: EnactVocabulary.modifier))])
            ))
        
        case let press as PressButton:
            .call(.call("press_button", [entry("button", word(press.button, of: EnactVocabulary.button))]))
        
        case let response as RespondBiometric:
            .call(.call("respond_biometric", [entry("outcome", word(response.outcome, of: EnactVocabulary.biometricOutcome))]))
        
        case let launch as LaunchApp:
            .call(.call(
                "launch_app",
                [entry("bundle_id", .quoted(launch.bundleID))]
                    + (launch.arguments.isEmpty ? [] : [entry("args", .sequence(launch.arguments.map(DraftNode.quoted)))])
                    + [launch.locale.map { locale in entry("locale", .quoted(locale)) }].compactMap { entry in entry }
                    + [launch.language.map { language in entry("language", .quoted(language)) }].compactMap { entry in entry }
            ))
        
        case let terminate as TerminateApp:
            .call(.call("terminate_app", [entry("bundle_id", .quoted(terminate.bundleID))]))
        
        case let uninstall as UninstallApp:
            .call(.call("uninstall_app", [entry("bundle_id", .quoted(uninstall.bundleID))]))
        
        case let install as InstallApp:
            .call(.call("install_app", [entry("path", .quoted(install.path))]))
        
        case let open as OpenURL:
            .call(.call("open_url", [entry("url", .quoted(open.url))]))
        
        case let push as PushNotification:
            payload(push.payload).map { payload in
                .call(.call("push_notification", [entry("bundle_id", .quoted(push.bundleID)), entry("payload", payload)]))
            }
        
        case let appearance as SetAppearance:
            .call(.call("set_appearance", [entry("value", word(appearance.appearance, of: EnactVocabulary.appearance))]))
        
        case let size as SetContentSize:
            .call(.call("set_content_size", [entry("value", word(size.size, of: EnactVocabulary.contentSize))]))
        
        case let contrast as SetContrast:
            .call(.call("set_contrast", [entry("value", word(contrast.contrast, of: EnactVocabulary.contrast))]))
        
        case let privacy as SetPrivacy:
            .call(privacyCall(privacy))
        
        case let location as SetLocation:
            .call(locationCall(try location.update()))
        
        case let statusBar as SetStatusBar:
            .call(statusBarCall(statusBar))
        
        case let orientation as SetOrientation:
            .call(.call("set_orientation", [entry("value", word(orientation.orientation, of: EnactVocabulary.orientation))]))
        
        case let hinge as SetHinge:
            .call(.call(hinge.hinge == .folded ? "fold" : "unfold"))
        
        case let keyboard as SetHardwareKeyboard:
            .call(.call(keyboard.keyboard == .connected ? "connect_hardware_keyboard" : "disconnect_hardware_keyboard"))
        
        case let accessibility as SetAppAccessibility:
            .call(.call(accessibility.accessibility == .enabled ? "enable_app_accessibility" : "disable_app_accessibility"))
        
        case let media as AddMedia:
            .call(.call("add_media", [entry("paths", .sequence(media.paths.map(DraftNode.quoted)))]))
        
        case let certificate as AddCertificate:
            .call(.call(certificate.root ? "add_root_certificate" : "add_certificate", [entry("path", .quoted(certificate.path))]))
        
        case is ResetKeychain:
            .call(.call("reset_keychain"))
        
        case let pasteboard as SetPasteboard:
            .call(.call("set_pasteboard", [entry("text", .quoted(pasteboard.text))]))
        
        default:
            nil
        }
    }
    
    private static func privacyCall(_ privacy: SetPrivacy) -> DraftNode {
        let services = entry("service", cases(privacy.services, of: EnactVocabulary.privacyService))
        
        guard let bundleID = privacy.bundleID else { return .call("reset_privacy", [services]) }
        
        return .call(
            "set_privacy",
            [entry("action", word(privacy.decision, of: EnactVocabulary.privacyDecision)), services, entry("bundle_id", .quoted(bundleID))]
        )
    }
    
    private static func locationCall(_ update: LocationUpdate) -> DraftNode {
        switch update {
        case let .fixed(point):
            .call("set_location", [entry("lat", .number(point.latitude)), entry("lon", .number(point.longitude))])
        
        case let .scenario(route):
            .call("set_location_route", [entry("route", .quoted(route))])
        
        case let .waypoints(waypoints, speed):
            .call(
                "set_location_waypoints",
                [entry("waypoints", .sequence(waypoints.map(coordinate)))]
                    + [speed.map { speed in entry("speed", .number(speed)) }].compactMap { entry in entry }
            )
        
        case .clear:
            .call("clear_location")
        }
    }
    
    private static func coordinate(_ coordinate: Coordinate) -> DraftNode {
        .struct([entry("lat", .number(coordinate.latitude)), entry("lon", .number(coordinate.longitude))])
    }
    
    private static func statusBarCall(_ statusBar: SetStatusBar) -> DraftNode {
        let given: [DraftNode.Entry?] = [
            statusBar.time.map { time in entry("time", .quoted(time)) },
            statusBar.dataNetwork.map { network in entry("data_network", word(network, of: EnactVocabulary.dataNetwork)) },
            statusBar.wifiMode.map { mode in entry("wifi_mode", word(mode, of: EnactVocabulary.wifiMode)) },
            statusBar.wifiBars.map { bars in entry("wifi_bars", .integer(bars)) },
            statusBar.cellularMode.map { mode in entry("cellular_mode", word(mode, of: EnactVocabulary.cellularMode)) },
            statusBar.cellularBars.map { bars in entry("cellular_bars", .integer(bars)) },
            statusBar.operatorName.map { name in entry("operator_name", .quoted(name)) },
            statusBar.batteryState.map { state in entry("battery_state", word(state, of: EnactVocabulary.batteryState)) },
            statusBar.batteryLevel.map { level in entry("battery_level", .integer(level)) }
        ]
        
        return .call("set_status_bar", given.compactMap { entry in entry })
    }
    
    // The payload as a dictionary literal, nil for one that is no JSON object.
    // The push refuses such a payload when it is performed, so the line is not
    // written.
    private static func payload(_ json: String) -> DraftNode? {
        guard let object = (try? JSONSerialization.jsonObject(with: Data(json.utf8))) as? [String: Any] else { return nil }
        
        return literal(object)
    }
    
    private static func literal(_ value: Any) -> DraftNode {
        switch value {
        case let object as [String: Any]:
            .dictionary(object.keys.sorted().map { key in entry(key, literal(object[key] as Any)) })
        
        case let array as [Any]:
            .sequence(array.map(literal))
        
        case let text as String:
            .quoted(text)
        
        case let number as NSNumber where CFGetTypeID(number) == CFBooleanGetTypeID():
            .bool(number.boolValue)
        
        case let number as NSNumber:
            CFNumberIsFloatType(number) ? .number(number.doubleValue) : .integer(number.intValue)
        
        default:
            .plain("null")
        }
    }
    
    private static func entry(_ key: String, _ value: DraftNode) -> DraftNode.Entry {
        DraftNode.Entry(key, value)
    }
    
    private static func word<Word>(_ word: Word, of set: WordSet<Word>) -> DraftNode {
        .enumCase(set.caseName(of: word))
    }
    
    private static func cases<Word>(_ words: [Word], of set: WordSet<Word>) -> DraftNode {
        .sequence(words.map { one in word(one, of: set) })
    }
}

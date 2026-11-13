//
//  EnactVocabulary.swift
//  EnactWarp
//
//  Created by JSilver on 10/31/26.
//

import Digit
import Foundation
import Warp
import WarpStandard
import WarpSyntax
import WarpYAML

// What Enact lends a scenario: the library document the binary carries,
// written in the YAML notation over the native verbs, the natives, and the
// standard vocabulary, with the front end a scenario written over them is
// read with.
package struct EnactVocabulary: Sendable {
    // MARK: - Property
    // The structs a look returns and a verb takes.
    static let screenType: Warp.Name = "Enact.Screen"
    static let snapshotType: Warp.Name = "Enact.Snapshot"
    static let frameType: Warp.Name = "Enact.Frame"
    static let pointType: Warp.Name = "Enact.Point"
    
    // The words a verb takes, each set an enum of its own.
    package static let role = WordSet<Role>("Enact.Role")
    static let direction = WordSet<Direction>("Enact.Direction")
    package static let button = WordSet<Button>("Enact.Button")
    package static let modifier = WordSet<Modifier>("Enact.Modifier")
    package static let biometricOutcome = WordSet<BiometricOutcome>("Enact.BiometricOutcome")
    package static let appearance = WordSet<Appearance>("Enact.Appearance")
    package static let contentSize = WordSet<ContentSize>("Enact.ContentSize")
    package static let contrast = WordSet<Contrast>("Enact.Contrast")
    package static let orientation = WordSet<Orientation>("Enact.Orientation")
    package static let privacyDecision = WordSet<SetPrivacyOperator.Decision>("Enact.PrivacyDecision")
    package static let privacyService = WordSet<PrivacyService>("Enact.PrivacyService")
    package static let dataNetwork = WordSet<DataNetwork>("Enact.DataNetwork")
    package static let wifiMode = WordSet<WifiMode>("Enact.WifiMode")
    package static let cellularMode = WordSet<CellularMode>("Enact.CellularMode")
    package static let batteryState = WordSet<BatteryState>("Enact.BatteryState")
    static let appState = WordSet<AppState>("Enact.AppState")
    
    // The modules the front end is handed beside the scenarios, whose names no
    // scenario is the module of.
    package static let modules: Set<String> = ["Enact", "Native", "Standard"]
    
    // The declarations of what the natives module brings, which the front end
    // reads apart from it: its types, part of the module `Enact` a scenario
    // uses, and its natives, the module `Native` only the library uses, since
    // each is named as the verb that calls it.
    private static let typeDeclarations = Dependency.interface(Data(Library.types.utf8), module: "Enact")
    private static let nativeDeclarations = Dependency.interface(Data(Library.natives.utf8), module: "Native")
    
    // Every standard bundle but running at once: a scenario drives one device.
    private static let standard = Module.sharedGround
        + Module.logic
        + Module.math
        + Module.text
        + Module.collection
        + Module.optional
        + Module.control
    
    // The natives that drive the device, by the verb each serves.
    private static let deviceActions: [String: any EnactAction.Type] = [
        "tap": TapAction.self,
        "tap_point": TapPointAction.self,
        "long_press": LongPressAction.self,
        "type_text": TypeTextAction.self,
        "move_slider": MoveSliderAction.self,
        "press_key": PressKeyAction.self,
        "press_button": PressButtonAction.self,
        "swipe": SwipeAction.self,
        "swipe_between": SwipeBetweenAction.self,
        "swipe_on": SwipeOnAction.self,
        "drag": DragAction.self,
        "drag_on": DragOnAction.self,
        "drag_toward": DragTowardAction.self,
        "respond_biometric": RespondBiometricAction.self,
        "launch_app": LaunchAppAction.self,
        "terminate_app": TerminateAppAction.self,
        "app_state": AppStateAction.self,
        "uninstall_app": UninstallAppAction.self,
        "install_app": InstallAppAction.self,
        "open_url": OpenURLAction.self,
        "push_notification": PushNotificationAction.self,
        "set_appearance": SetAppearanceAction.self,
        "set_content_size": SetContentSizeAction.self,
        "set_contrast": SetContrastAction.self,
        "set_privacy": SetPrivacyAction.self,
        "reset_privacy": ResetPrivacyAction.self,
        "set_location": SetLocationAction.self,
        "set_location_route": SetLocationRouteAction.self,
        "set_location_waypoints": SetLocationWaypointsAction.self,
        "clear_location": ClearLocationAction.self,
        "set_status_bar": SetStatusBarAction.self,
        "clear_status_bar": ClearStatusBarAction.self,
        "set_orientation": SetOrientationAction.self,
        "fold": FoldAction.self,
        "unfold": UnfoldAction.self,
        "connect_hardware_keyboard": ConnectHardwareKeyboardAction.self,
        "disconnect_hardware_keyboard": DisconnectHardwareKeyboardAction.self,
        "is_app_accessibility_enabled": IsAppAccessibilityEnabledAction.self,
        "enable_app_accessibility": EnableAppAccessibilityAction.self,
        "disable_app_accessibility": DisableAppAccessibilityAction.self,
        "add_media": AddMediaAction.self,
        "add_certificate": AddCertificateAction.self,
        "add_root_certificate": AddRootCertificateAction.self,
        "reset_keychain": ResetKeychainAction.self,
        "screenshot": ScreenshotAction.self,
        "set_pasteboard": SetPasteboardAction.self,
        "read_pasteboard": ReadPasteboardAction.self,
        "look": LookAction.self,
        "element_at": ElementAtAction.self,
        "record": RecordAction.self,
        "record_log": RecordLogAction.self
    ]
    
    // The natives that drive no device: the questions over a look, and the
    // run's own control.
    private static let controls: [String: Native] = [
        "within": .query(WithinQuery()),
        "in_area": .query(InAreaQuery()),
        "fully_visible": .query(FullyVisibleQuery()),
        "nearest": .query(NearestQuery()),
        "repeat": .effect(RepeatAction()),
        "sleep": .effect(SleepAction())
    ]
    
    let library: Value
    
    // What every link holds beside the scenarios.
    package let linkables: [Module]
    
    // MARK: - Initializer
    package init() throws {
        let library = try BinaryEncoding().value(
            from: try YAMLFrontend().depending(on: [Self.typeDeclarations, Self.nativeDeclarations]).document(from: Library.text).document
        )
        
        self.library = library
        self.linkables = [try Loader().load(library), try Self.natives()] + Self.standard
    }
    
    // MARK: - Public
    // The natives module: its types and what each native takes and gives as
    // the interfaces declare them, each native carried out by its Swift, whose
    // parameters name only where it reads each argument.
    static func natives() throws -> Module {
        let types = try Loader().interface(try TextEncoding().value(from: Library.types))
        let declared = try Loader().interface(try TextEncoding().value(from: Library.natives))
        let implementations = try implementations()
        
        return try Module(
            types: types.types,
            procedures: declared.procedures.reduce(into: [:]) { procedures, entry in
                guard let implementation = implementations[entry.key] else { return }
                
                procedures[entry.key] = Procedure(
                    access: entry.value.access,
                    signature: entry.value.signature,
                    implementation: implementation
                )
            }
        )
    }
    
    // Each native's Swift, by the name the library calls it.
    static func implementations() throws -> [Warp.Name: Native] {
        let devices = try deviceActions.map { verb, action in (try native(verb), Native.effect(action.init())) }
        let others = try controls.map { verb, implementation in (try native(verb), implementation) }
        
        return Dictionary(uniqueKeysWithValues: devices + others)
    }
    
    // The front end a scenario is read with: depending on the module `Enact`,
    // the library and the types beside it, and on the scenarios it may call,
    // each the module of the name it declares.
    package func frontend(dependingOn scenarios: [(module: String, text: String)] = []) throws -> YAMLFrontend {
        try YAMLFrontend().depending(
            on: [.text(Library.text, module: "Enact"), Self.typeDeclarations]
                + scenarios.map { scenario in .text(scenario.text, module: try WarpYAML.Name(scenario.module)) }
        )
    }
    
    // What a run starting at entry may ask the device for: each operation,
    // with the verbs that ask it.
    package static func operations(reachedFrom entry: Warp.Name, in image: Image) throws -> [Digit.Operation: Set<String>] {
        let reached = try image.reached(from: entry)
        
        return try deviceActions.reduce(into: [:]) { asked, device in
            guard reached.contains(try native(device.key)) else { return }
            
            for operation in device.value.operations {
                asked[operation, default: []].insert(device.key)
            }
        }
    }
    
    // MARK: - Private
    // The name the library calls a verb's native by.
    private static func native(_ verb: String) throws -> Warp.Name {
        try Warp.Name("Enact.Native.\(verb)")
    }
}

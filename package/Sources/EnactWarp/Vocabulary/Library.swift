//
//  Library.swift
//  EnactWarp
//
//  Written by tool/embed-library.sh. Edit lib/ and run it again.
//

import Foundation

// The texts of `lib/`, as they stand in the repository.
enum Library {
    // `lib/Enact.yaml`
    static let text = """
        # Enact's grammar: the verbs a scenario writes, each over the native verb a
        # run lends it, with its parameters named and its defaults.
        name: Enact
        uses: [Enact, Native]
        
        procedures:
          tap:
            description: Taps a snapshot, at its middle or at a point given as fractions of its frame. A disabled snapshot, or a point off the screen, is reference_unfit.
            access: public
            parameters:
              - on: { type: "Enact.Snapshot", hint: "what to tap, from a look" }
              - at: { type: "Enact.Point?", hint: "fractions of its frame, its middle where left out" }
            failing: [device_refused, argument_refused, reference_unfit]
            result:
              call:
                procedure: Enact.Native.tap
                arguments: [ { ref: on }, { ref: at } ]
        
          tap_point:
            description: Taps a point of the screen, given as fractions of it, for what no look can name.
            access: public
            parameters:
              - at: { type: "Enact.Point", hint: "fractions of the screen" }
            failing: [device_refused, argument_refused]
            result:
              call:
                procedure: Enact.Native.tap_point
                arguments: [ { ref: at } ]
        
          long_press:
            description: Holds a press on a snapshot for duration seconds. A disabled snapshot, or a point off the screen, is reference_unfit.
            access: public
            parameters:
              - on: { type: "Enact.Snapshot", hint: "what to press, from a look" }
              - at: { type: "Enact.Point?", hint: "fractions of its frame, its middle where left out" }
              - duration: { type: "Double", default: 0.5, hint: "seconds the press is held" }
            failing: [device_refused, argument_refused, reference_unfit]
            result:
              call:
                procedure: Enact.Native.long_press
                arguments: [ { ref: on }, { ref: at }, { ref: duration } ]
        
          type_text:
            description: Types text by tapping the keys of the software keyboard on the screen, into whatever it types into, in any keyboard the device has, Korean on the two-set keys. Fails with no software keyboard on the screen; a connected hardware keyboard keeps it away, and a keyboard still coming up is waited for with wait_for on an element whose role is key. A character no keyboard of the device has is refused before anything is typed. The keyboard is left as it was found.
            access: public
            parameters:
              - text: String
            failing: [device_refused, argument_refused]
            result:
              call:
                procedure: Enact.Native.type_text
                arguments: [ { ref: text } ]
        
          move_slider:
            description: Drags a slider's thumb along its rail to value, a fraction from 0 to 1.
            access: public
            parameters:
              - on: { type: "Enact.Snapshot", hint: "a slider, from a look" }
              - value: { type: "Double", hint: "where the thumb ends, a fraction of the rail" }
            failing: [device_refused, argument_refused, reference_unfit]
            result:
              call:
                procedure: Enact.Native.move_slider
                arguments: [ { ref: on }, { ref: value } ]
        
          press_key:
            description: Presses a key, named or a character, with modifiers held.
            access: public
            parameters:
              - key: { type: "String", hint: "a character, or a key's name such as return or page-up" }
              - modifiers: { type: "Array<Enact.Modifier>", default: [] }
            failing: [device_refused, argument_refused]
            result:
              call:
                procedure: Enact.Native.press_key
                arguments: [ { ref: key }, { ref: modifiers } ]
        
          press_button:
            description: Presses a hardware button.
            access: public
            parameters:
              - button: Enact.Button
            failing: [device_refused, argument_refused]
            result:
              call:
                procedure: Enact.Native.press_button
                arguments: [ { ref: button } ]
        
          swipe:
            description: Swipes across the screen so its content moves in direction.
            access: public
            parameters:
              - direction: Enact.Direction
              - duration: { type: "Double", default: 0.2, hint: "seconds the stroke takes" }
            failing: [device_refused, argument_refused]
            result:
              call:
                procedure: Enact.Native.swipe
                arguments: [ { ref: direction }, { ref: duration } ]
        
          swipe_between:
            description: Swipes from one point to another, each given as fractions of the screen.
            access: public
            parameters:
              - from: { type: "Enact.Point", hint: "fractions of the screen" }
              - to: { type: "Enact.Point", hint: "fractions of the screen" }
              - duration: { type: "Double", default: 0.2, hint: "seconds the stroke takes" }
            failing: [device_refused, argument_refused]
            result:
              call:
                procedure: Enact.Native.swipe_between
                arguments: [ { ref: from }, { ref: to }, { ref: duration } ]
        
          swipe_on:
            description: Swipes inside a snapshot so its content moves in direction, across the part of it the screen shows.
            access: public
            parameters:
              - on: { type: "Enact.Snapshot", hint: "what to swipe in, such as a list, from a look" }
              - direction: Enact.Direction
              - duration: { type: "Double", default: 0.2, hint: "seconds the stroke takes" }
            failing: [device_refused, argument_refused, reference_unfit]
            result:
              call:
                procedure: Enact.Native.swipe_on
                arguments: [ { ref: on }, { ref: direction }, { ref: duration } ]
        
          drag:
            description: Presses at one point, moves to another and lets go, each given as fractions of the screen.
            access: public
            parameters:
              - from: { type: "Enact.Point", hint: "fractions of the screen" }
              - to: { type: "Enact.Point", hint: "fractions of the screen" }
              - duration: { type: "Double", default: 0.2, hint: "seconds the move takes" }
            failing: [device_refused, argument_refused]
            result:
              call:
                procedure: Enact.Native.drag
                arguments: [ { ref: from }, { ref: to }, { ref: duration } ]
        
          respond_biometric:
            description: Answers a Face ID or Touch ID prompt.
            access: public
            parameters:
              - outcome: { type: "Enact.BiometricOutcome", default: { case: match } }
            failing: [device_refused, argument_refused]
            result:
              call:
                procedure: Enact.Native.respond_biometric
                arguments: [ { ref: outcome } ]
        
          launch_app:
            description: Launches an app, with arguments, and a locale and a language where given. An app already running is terminated and launched anew. It returns once the app's process starts, and until the app draws, a look reads the app that was in front or none of this one, so wait_for what its first screen shows; app_state tells whether it is in front yet.
            access: public
            parameters:
              - bundle_id: String
              - args: { type: "Array<String>", default: [], hint: "arguments the app is launched with" }
              - locale: "String?"
              - language: "String?"
            failing: [device_refused, argument_refused]
            result:
              call:
                procedure: Enact.Native.launch_app
                arguments: [ { ref: bundle_id }, { ref: args }, { ref: locale }, { ref: language } ]
        
          terminate_app:
            description: Terminates an app.
            access: public
            parameters:
              - bundle_id: String
            failing: [device_refused, argument_refused]
            result:
              call:
                procedure: Enact.Native.terminate_app
                arguments: [ { ref: bundle_id } ]
        
          app_state:
            description: Whether an app is not running, in the background, or in the foreground, the app the screen shows. It reads the screen once.
            access: public
            parameters:
              - bundle_id: String
            returns: "Enact.AppState"
            failing: [device_refused, argument_refused]
            result:
              call:
                procedure: Enact.Native.app_state
                arguments: [ { ref: bundle_id } ]
        
          uninstall_app:
            description: Uninstalls an app.
            access: public
            parameters:
              - bundle_id: String
            failing: [device_refused, argument_refused]
            result:
              call:
                procedure: Enact.Native.uninstall_app
                arguments: [ { ref: bundle_id } ]
        
          install_app:
            description: Installs the app at path.
            access: public
            parameters:
              - path: { type: "String", hint: "an .app or .ipa on this machine" }
            failing: [device_refused, argument_refused]
            result:
              call:
                procedure: Enact.Native.install_app
                arguments: [ { ref: path } ]
        
          open_url:
            description: Opens a URL, a web page or a deep link.
            access: public
            parameters:
              - url: String
            failing: [device_refused, argument_refused]
            result:
              call:
                procedure: Enact.Native.open_url
                arguments: [ { ref: url } ]
        
          push_notification:
            description: Delivers a push notification to an app.
            access: public
            parameters:
              - bundle_id: String
              - payload: { type: "Dictionary<String, Any>", hint: "the APNs payload, { dictionary: { aps: { dictionary: { alert: Hi } } } }" }
            failing: [device_refused, argument_refused]
            result:
              call:
                procedure: Enact.Native.push_notification
                arguments: [ { ref: bundle_id }, { ref: payload } ]
        
          set_appearance:
            description: Sets light or dark appearance.
            access: public
            parameters:
              - value: Enact.Appearance
            failing: [device_refused, argument_refused]
            result:
              call:
                procedure: Enact.Native.set_appearance
                arguments: [ { ref: value } ]
        
          set_content_size:
            description: Sets the preferred text size.
            access: public
            parameters:
              - value: Enact.ContentSize
            failing: [device_refused, argument_refused]
            result:
              call:
                procedure: Enact.Native.set_content_size
                arguments: [ { ref: value } ]
        
          set_contrast:
            description: Sets standard or increased contrast.
            access: public
            parameters:
              - value: Enact.Contrast
            failing: [device_refused, argument_refused]
            result:
              call:
                procedure: Enact.Native.set_contrast
                arguments: [ { ref: value } ]
        
          set_privacy:
            description: Grants, revokes or resets an app's access to services.
            access: public
            parameters:
              - action: Enact.PrivacyDecision
              - service: "Array<Enact.PrivacyService>"
              - bundle_id: String
            failing: [device_refused, argument_refused]
            result:
              call:
                procedure: Enact.Native.set_privacy
                arguments: [ { ref: action }, { ref: service }, { ref: bundle_id } ]
        
          reset_privacy:
            description: Resets every app's access to services.
            access: public
            parameters:
              - service: "Array<Enact.PrivacyService>"
            failing: [device_refused, argument_refused]
            result:
              call:
                procedure: Enact.Native.reset_privacy
                arguments: [ { ref: service } ]
        
          set_location:
            description: Puts the device at a latitude and longitude.
            access: public
            parameters:
              - lat: Double
              - lon: Double
            failing: [device_refused, argument_refused]
            result:
              call:
                procedure: Enact.Native.set_location
                arguments: [ { ref: lat }, { ref: lon } ]
        
          set_location_route:
            description: Moves the device along a named route.
            access: public
            parameters:
              - route: { type: "String", hint: "a route the simulator knows, such as City Run" }
            failing: [device_refused, argument_refused]
            result:
              call:
                procedure: Enact.Native.set_location_route
                arguments: [ { ref: route } ]
        
          set_location_waypoints:
            description: Moves the device from each waypoint to the next, in order.
            access: public
            parameters:
              - waypoints: { type: "Array<Enact.Coordinate>", hint: "two or more, each { struct: { lat: 37.5, lon: 127 } }" }
              - speed: { type: "Double?", hint: "metres per second, the simulator's own when left out" }
            failing: [device_refused, argument_refused]
            result:
              call:
                procedure: Enact.Native.set_location_waypoints
                arguments: [ { ref: waypoints }, { ref: speed } ]
        
          clear_location:
            description: Stops simulating a location.
            access: public
            failing: [device_refused, argument_refused]
            result:
              call:
                procedure: Enact.Native.clear_location
        
          set_status_bar:
            description: Overrides what the status bar shows.
            access: public
            parameters:
              - time: "String?"
              - data_network: "Enact.DataNetwork?"
              - wifi_mode: "Enact.WifiMode?"
              - wifi_bars: { type: "Int?", hint: "0 to 3" }
              - cellular_mode: "Enact.CellularMode?"
              - cellular_bars: { type: "Int?", hint: "0 to 4" }
              - operator_name: "String?"
              - battery_state: "Enact.BatteryState?"
              - battery_level: { type: "Int?", hint: "0 to 100" }
            failing: [device_refused, argument_refused]
            result:
              call:
                procedure: Enact.Native.set_status_bar
                arguments:
                  - { ref: time }
                  - { ref: data_network }
                  - { ref: wifi_mode }
                  - { ref: wifi_bars }
                  - { ref: cellular_mode }
                  - { ref: cellular_bars }
                  - { ref: operator_name }
                  - { ref: battery_state }
                  - { ref: battery_level }
        
          clear_status_bar:
            description: Gives the status bar back to the device.
            access: public
            failing: [device_refused, argument_refused]
            result:
              call:
                procedure: Enact.Native.clear_status_bar
        
          set_orientation:
            description: Turns the device. The interface follows where the app turns with it.
            access: public
            parameters:
              - value: Enact.Orientation
            failing: [device_refused, argument_refused]
            result:
              call:
                procedure: Enact.Native.set_orientation
                arguments: [ { ref: value } ]
        
          fold:
            description: Folds a device that folds, and returns once its outer screen is on.
            access: public
            failing: [device_refused, argument_refused]
            result:
              call:
                procedure: Enact.Native.fold
        
          unfold:
            description: Unfolds a device that folds, and returns once its inner screen is on.
            access: public
            failing: [device_refused, argument_refused]
            result:
              call:
                procedure: Enact.Native.unfold
        
          connect_hardware_keyboard:
            description: Connects the hardware keyboard, which hides the software keyboard.
            access: public
            failing: [device_refused, argument_refused]
            result:
              call:
                procedure: Enact.Native.connect_hardware_keyboard
        
          disconnect_hardware_keyboard:
            description: Disconnects the hardware keyboard, so a field with the focus shows the software keyboard.
            access: public
            failing: [device_refused, argument_refused]
            result:
              call:
                procedure: Enact.Native.disconnect_hardware_keyboard
        
          is_app_accessibility_enabled:
            description: Whether application accessibility is on. An app serves the elements a look reads only while it is.
            access: public
            returns: Bool
            failing: [device_refused, argument_refused]
            result:
              call:
                procedure: Enact.Native.is_app_accessibility_enabled
        
          enable_app_accessibility:
            description: Turns application accessibility on. A look, or anything else that reads the screen, turns it on itself where it is off.
            access: public
            failing: [device_refused, argument_refused]
            result:
              call:
                procedure: Enact.Native.enable_app_accessibility
        
          disable_app_accessibility:
            description: Turns application accessibility off, as a device is left after a run. Apps already serving their elements keep serving them, and the next read of the screen turns it on again.
            access: public
            failing: [device_refused, argument_refused]
            result:
              call:
                procedure: Enact.Native.disable_app_accessibility
        
          add_media:
            description: Adds photos and videos to the library.
            access: public
            parameters:
              - paths: { type: "Array<String>", hint: "files on this machine" }
            failing: [device_refused, argument_refused]
            result:
              call:
                procedure: Enact.Native.add_media
                arguments: [ { ref: paths } ]
        
          add_certificate:
            description: Adds a certificate to the keychain.
            access: public
            parameters:
              - path: { type: "String", hint: "a certificate file on this machine" }
            failing: [device_refused, argument_refused]
            result:
              call:
                procedure: Enact.Native.add_certificate
                arguments: [ { ref: path } ]
        
          add_root_certificate:
            description: Adds a certificate to the trusted root store, so the device trusts what it signs, as a proxy's.
            access: public
            parameters:
              - path: { type: "String", hint: "a certificate file on this machine" }
            failing: [device_refused, argument_refused]
            result:
              call:
                procedure: Enact.Native.add_root_certificate
                arguments: [ { ref: path } ]
        
          reset_keychain:
            description: Empties the keychain. A certificate trusted as a root stays trusted until the device is erased.
            access: public
            failing: [device_refused, argument_refused]
            result:
              call:
                procedure: Enact.Native.reset_keychain
        
          screenshot:
            description: Saves a screenshot in the out dir and returns where.
            access: public
            parameters:
              - name: { type: "String?", hint: "a file name, shot where left out" }
            returns: String
            failing: [device_refused, argument_refused]
            result:
              call:
                procedure: Enact.Native.screenshot
                arguments: [ { ref: name } ]
        
          set_pasteboard:
            description: Puts text on the pasteboard, and is device_refused where the pasteboard does not read it back.
            access: public
            parameters:
              - text: String
            failing: [device_refused, argument_refused]
            result:
              call:
                procedure: Enact.Native.set_pasteboard
                arguments: [ { ref: text } ]
        
          read_pasteboard:
            description: Reads the text on the pasteboard.
            access: public
            returns: String
            failing: [device_refused, argument_refused]
            result: { call: { procedure: Enact.Native.read_pasteboard } }
        
        
          look:
            description: Reads the screen once, its size and every element on it in reading order, each before the elements inside it. What another process draws inside the app, as a web view's content, is found by pressing at points a grid apart and follows the app's own elements, one by one with none inside another, so an element smaller than the grid can be missed.
            access: public
            returns: Enact.Screen
            failing: [device_refused, argument_refused]
            result: { call: { procedure: Enact.Native.look } }
        
          element_at:
            description: Reads the element a press at a point of the screen lands on, given as fractions of it, or none where nothing answers. It stands in no look, so its index_path is empty.
            access: public
            parameters:
              - at: { type: "Enact.Point", hint: "fractions of the screen" }
            returns: "Enact.Snapshot?"
            failing: [device_refused, argument_refused]
            result:
              call:
                procedure: Enact.Native.element_at
                arguments: [ { ref: at } ]
        
          within:
            description: The snapshots that sit inside a container at any depth, as the tree of one look says.
            access: public
            const: true
            isolated: true
            parameters:
              - elements: "Array<Enact.Snapshot>"
              - in: { type: "Enact.Snapshot", hint: "the container, from the same look" }
            returns: "Array<Enact.Snapshot>"
            result:
              call:
                procedure: Enact.Native.within
                arguments: [ { ref: elements }, { ref: in } ]
        
          in_area:
            description: The snapshots whose frame meets an area of the screen.
            access: public
            const: true
            isolated: true
            parameters:
              - elements: "Array<Enact.Snapshot>"
              - area: { type: "Enact.Frame", hint: "fractions of the screen's width and height" }
              - screen: { type: "Enact.Screen", hint: "the look the snapshots came from" }
            returns: "Array<Enact.Snapshot>"
            failing: [argument_refused]
            result:
              call:
                procedure: Enact.Native.in_area
                arguments: [ { ref: elements }, { ref: area }, { ref: screen } ]
        
          nearest:
            description: The snapshots ordered by how far the middle of each is from a point of the screen, the nearest first.
            access: public
            const: true
            isolated: true
            parameters:
              - elements: "Array<Enact.Snapshot>"
              - to: { type: "Enact.Point", hint: "fractions of the screen's width and height" }
              - screen: { type: "Enact.Screen", hint: "the look the snapshots came from" }
            returns: "Array<Enact.Snapshot>"
            failing: [argument_refused]
            result:
              call:
                procedure: Enact.Native.nearest
                arguments: [ { ref: elements }, { ref: to }, { ref: screen } ]
        
          screen_point:
            description: The point of the screen at fractions of a snapshot's frame, as fractions of the screen, for element_at and tap_point. The fractions may fall outside the frame, beside it, as a menu shown under a field stands.
            access: public
            const: true
            isolated: true
            parameters:
              - on: { type: "Enact.Snapshot", hint: "the element the point is given against, from a look" }
              - at: { type: "Enact.Point", hint: "fractions of its frame, below 0 or above 1 for outside it" }
              - screen: { type: "Enact.Screen", hint: "the look the snapshot came from" }
            returns: "Enact.Point"
            result:
              struct:
                x: { of: { of: { ref: on.frame.x }, plus: { of: { ref: on.frame.width }, times: { ref: at.x } } }, divided_by: { ref: screen.width } }
                y: { of: { of: { ref: on.frame.y }, plus: { of: { ref: on.frame.height }, times: { ref: at.y } } }, divided_by: { ref: screen.height } }
        
          record:
            description: Records video of the device while body runs into the out dir, and returns what body returned.
            access: public
            parameters:
              - name: { type: String?, hint: "a file name, video where left out" }
              - body: { type: "() throws -> some Result", hint: "what is recorded" }
            returns: some Result
            failing: anything
            result:
              call:
                procedure: Enact.Native.record
                arguments: [ { ref: name }, { ref: body } ]
        
          record_log:
            description: Writes the device's log stream while body runs into the out dir, and returns what body returned.
            access: public
            parameters:
              - name: { type: String?, hint: "a file name, log where left out" }
              - predicate: { type: String?, hint: "a log stream predicate the lines are filtered by, every line where left out" }
              - body: { type: "() throws -> some Result", hint: "what is logged" }
            returns: some Result
            failing: anything
            result:
              call:
                procedure: Enact.Native.record_log
                arguments: [ { ref: name }, { ref: predicate }, { ref: body } ]
        
          repeat:
            description: Runs body round after round until until holds of what a round returned, and returns it.
            access: public
            parameters:
              - timeout: { type: Double, hint: "seconds it may spend before timed_out" }
              - debounce: { type: Double?, hint: "seconds what until took must come back the same" }
              - body: { type: "() throws -> some Result", hint: "one round" }
              - until: { type: "(some Result) throws -> Bool", hint: "whether a round returned what is waited for" }
            returns: some Result
            failing: anything
            result:
              call:
                procedure: Enact.Native.repeat
                arguments: [ { ref: timeout }, { ref: debounce }, { ref: body }, { ref: until } ]
        
          sleep:
            description: Waits sec seconds. because says what the wait is for.
            access: public
            parameters:
              - sec: { type: Double, hint: "seconds to wait, not negative" }
              - because: { type: String, hint: "what the wait is for, not empty" }
            failing: [argument_refused]
            result:
              call:
                procedure: Enact.Native.sleep
                arguments: [ { ref: sec }, { ref: because } ]
        
          # Compositions: procedures over the verbs above. They call verbs, never a
          # native, so each says nothing a scenario could not say itself.
        
          displayed_text:
            description: The text a snapshot shows. A field shows its value, a heading or a text its label, or its value where its label is empty, and anything else its label; a snapshot showing neither shows the empty text.
            access: public
            const: true
            isolated: true
            parameters:
              - of: { type: "Enact.Snapshot", hint: "the element, from a look" }
            returns: String
            body:
              - let: label
                value:
                  call:
                    procedure: Standard.Optional.unwrapped
                    arguments: [ { ref: of.label }, { closure: { const: true, isolated: true, returns: String, body: [ { value: { return: "" } } ] } } ]
              - var: shown
                type: "String?"
                value: { ref: label }
              - value:
                  switch:
                    of: { ref: of.role }
                    cases:
                      field: { then: [ { set: shown, value: { ref: of.value } } ] }
                      secureField: { then: [ { set: shown, value: { ref: of.value } } ] }
                      heading: { then: [ { value: { cases: [ { when: { of: { ref: label }, is: "" }, then: [ { set: shown, value: { ref: of.value } } ] } ] } } ] }
                      text: { then: [ { value: { cases: [ { when: { of: { ref: label }, is: "" }, then: [ { set: shown, value: { ref: of.value } } ] } ] } } ] }
                    default: []
            result:
              call:
                procedure: Standard.Optional.unwrapped
                arguments: [ { ref: shown }, { closure: { const: true, isolated: true, returns: String, body: [ { value: { return: "" } } ] } } ]
        
          paste_text:
            description: Puts text where the focus is by pasting it, for text no key types, or typed faster than key by key. What was on the pasteboard is replaced.
            access: public
            parameters:
              - text: String
            failing: [device_refused, argument_refused]
            body:
              - value: { call: { procedure: set_pasteboard, arguments: { text: { ref: text } } } }
              - value: { call: { procedure: press_key, arguments: { key: v, modifiers: [ { case: command } ] } } }
        
          clear_text:
            description: Presses command-A, then delete once, where the focus is, the keys leaving the software keyboard up. In a field where command-A selects all, its text is emptied; in one that keeps command-A from selecting, only the character before the caret is deleted. Whether the field is empty is read from a look.
            access: public
            failing: [device_refused, argument_refused]
            body:
              - value: { call: { procedure: press_key, arguments: { key: a, modifiers: [ { case: command } ] } } }
              - value: { call: { procedure: press_key, arguments: { key: delete } } }
        
          wait_for:
            description: Looks until an element that where holds of is on the screen and stays put, and returns the first in reading order.
            access: public
            parameters:
              - where: { type: "const isolated (Enact.Snapshot) -> Bool", hint: "whether an element is the one waited for" }
              - timeout: { type: Double, default: 10, hint: "seconds it may look before timed_out" }
              - debounce: { type: Double, default: 0.5, hint: "seconds what was found must come back the same, so it is not caught moving" }
            returns: Enact.Snapshot
            failing: anything
            body:
              - let: found
                value:
                  call:
                    procedure: repeat
                    arguments:
                      timeout: { ref: timeout }
                      debounce: { ref: debounce }
                      body:
                        closure:
                          returns: "Array<Enact.Snapshot>"
                          body:
                            - let: seen
                              value: { call: { procedure: look } }
                          result: { of: { ref: seen.elements }, filter: { ref: where } }
                      until: { closure: { parameters: [ held: "Array<Enact.Snapshot>" ], result: { of: { count: { ref: held } }, greater_than: 0 } } }
            result: { ref: "found[0]" }
        
          scroll_to:
            description: Swipes inside a snapshot until an element that where holds of is on the screen and stays put, and returns the first in reading order.
            access: public
            parameters:
              - where: { type: "const isolated (Enact.Snapshot) -> Bool", hint: "whether an element is the one scrolled to" }
              - on: { type: "Enact.Snapshot", hint: "what to swipe in, such as a list, from a look" }
              - direction: { type: Enact.Direction, hint: "the way the content moves, up to bring what is below into view" }
              - timeout: { type: Double, default: 30, hint: "seconds it may scroll before timed_out" }
              - debounce: { type: Double, default: 0.5, hint: "seconds what was found must come back the same, so it is not caught moving" }
            returns: Enact.Snapshot
            failing: anything
            body:
              - let: found
                value:
                  call:
                    procedure: repeat
                    arguments:
                      timeout: { ref: timeout }
                      debounce: { ref: debounce }
                      body:
                        closure:
                          returns: "Array<Enact.Snapshot>"
                          body:
                            - let: seen
                              value: { call: { procedure: look } }
                            - let: matched
                              value: { of: { ref: seen.elements }, filter: { ref: where } }
                            - value:
                                cases:
                                  - when: { of: { count: { ref: matched } }, is: 0 }
                                    then:
                                      - value: { call: { procedure: swipe_on, arguments: { on: { ref: on }, direction: { ref: direction } } } }
                          result: { ref: matched }
                      until: { closure: { parameters: [ held: "Array<Enact.Snapshot>" ], result: { of: { count: { ref: held } }, greater_than: 0 } } }
            result: { ref: "found[0]" }
        """
    
    // `lib/Enact.interface.warpt`
    static let types = """
        (interface 1)
        
        (enum Enact.AppState
          (case background)
          (case foreground)
          (case notRunning))
        
        (enum Enact.Appearance
          (case dark)
          (case light))
        
        (enum Enact.BatteryState
          (case charged)
          (case charging)
          (case discharging))
        
        (enum Enact.BiometricOutcome
          (case match)
          (case noMatch))
        
        (enum Enact.Button
          (case applePay)
          (case home)
          (case lock)
          (case side)
          (case siri))
        
        (enum Enact.CellularMode
          (case active)
          (case failed)
          (case notSupported)
          (case searching))
        
        (enum Enact.ContentSize
          (case accessibilityExtraExtraExtraLarge)
          (case accessibilityExtraExtraLarge)
          (case accessibilityExtraLarge)
          (case accessibilityLarge)
          (case accessibilityMedium)
          (case extraExtraExtraLarge)
          (case extraExtraLarge)
          (case extraLarge)
          (case extraSmall)
          (case large)
          (case medium)
          (case small))
        
        (enum Enact.Contrast
          (case increased)
          (case standard))
        
        (struct Enact.Coordinate
          (field lat Double)
          (field lon Double))
        
        (enum Enact.DataNetwork
          (case fiveG)
          (case fiveGPlus)
          (case fiveGUltraCapacity)
          (case fiveGUltraWideband)
          (case fourG)
          (case hide)
          (case lte)
          (case lteAdvanced)
          (case ltePlus)
          (case threeG)
          (case wifi))
        
        (enum Enact.Direction
          (case down)
          (case left)
          (case right)
          (case up))
        
        (struct Enact.Frame
          (field height Double)
          (field width Double)
          (field x Double)
          (field y Double))
        
        (enum Enact.Modifier
          (case command)
          (case control)
          (case option)
          (case shift))
        
        (struct Enact.Point
          (field x Double)
          (field y Double))
        
        (enum Enact.Orientation
          (case landscapeLeft)
          (case landscapeRight)
          (case portrait)
          (case portraitUpsideDown))
        
        (enum Enact.PrivacyDecision
          (case grant)
          (case reset)
          (case revoke))
        
        (enum Enact.PrivacyService
          (case all)
          (case calendar)
          (case camera)
          (case contacts)
          (case contactsLimited)
          (case location)
          (case locationAlways)
          (case mediaLibrary)
          (case microphone)
          (case motion)
          (case photos)
          (case photosAdd)
          (case reminders)
          (case siri))
        
        (enum Enact.Role
          (case alert)
          (case bar)
          (case button)
          (case container)
          (case field)
          (case heading)
          (case image)
          (case key)
          (case link)
          (case map)
          (case picker)
          (case progress)
          (case secureField)
          (case slider)
          (case text)
          (case toggle)
          (case unknown)
          (case web))
        
        (struct Enact.Screen
          (field elements (array Enact.Snapshot))
          (field height Double)
          (field width Double))
        
        (struct Enact.Snapshot
          (field actions (array String))
          (field enabled Bool)
          (field frame Enact.Frame)
          (field id (optional String))
          (field index_path (array Int))
          (field label (optional String))
          (field role Enact.Role)
          (field track (optional Enact.Frame))
          (field value (optional String)))
        
        (enum Enact.WifiMode
          (case active)
          (case failed)
          (case searching))
        """
    
    // `lib/Native.interface.warpt`
    static let natives = """
        (interface 1)
        
        (import Enact.AppState)
        (import Enact.Appearance)
        (import Enact.BatteryState)
        (import Enact.BiometricOutcome)
        (import Enact.Button)
        (import Enact.CellularMode)
        (import Enact.ContentSize)
        (import Enact.Contrast)
        (import Enact.Coordinate)
        (import Enact.DataNetwork)
        (import Enact.Direction)
        (import Enact.Frame)
        (import Enact.Modifier)
        (import Enact.Orientation)
        (import Enact.Point)
        (import Enact.PrivacyDecision)
        (import Enact.PrivacyService)
        (import Enact.Screen)
        (import Enact.Snapshot)
        (import Enact.WifiMode)
        
        (procedure Enact.Native.app_state
          (parameter bundle_id (type String))
          (returns Enact.AppState)
          (failing argument_refused device_refused))
        
        (procedure Enact.Native.add_certificate
          (parameter path (type String))
          (failing argument_refused device_refused))
        
        (procedure Enact.Native.add_media
          (parameter paths (type (array String)))
          (failing argument_refused device_refused))
        
        (procedure Enact.Native.add_root_certificate
          (parameter path (type String))
          (failing argument_refused device_refused))
        
        (procedure Enact.Native.clear_location
          (failing argument_refused device_refused))
        
        (procedure Enact.Native.clear_status_bar
          (failing argument_refused device_refused))
        
        (procedure Enact.Native.connect_hardware_keyboard
          (failing argument_refused device_refused))
        
        (procedure Enact.Native.disable_app_accessibility
          (failing argument_refused device_refused))
        
        (procedure Enact.Native.disconnect_hardware_keyboard
          (failing argument_refused device_refused))
        
        (procedure Enact.Native.drag
          (parameter from (type Enact.Point))
          (parameter to (type Enact.Point))
          (parameter duration (type Double))
          (failing argument_refused device_refused))
        
        (procedure Enact.Native.element_at
          (parameter at (type Enact.Point))
          (returns (optional Enact.Snapshot))
          (failing argument_refused device_refused))
        
        (procedure Enact.Native.enable_app_accessibility
          (failing argument_refused device_refused))
        
        (procedure Enact.Native.fold
          (failing argument_refused device_refused))
        
        (procedure Enact.Native.in_area
          (const)
          (isolated)
          (parameter elements (type (array Enact.Snapshot)))
          (parameter area (type Enact.Frame))
          (parameter screen (type Enact.Screen))
          (returns (array Enact.Snapshot))
          (failing argument_refused))
        
        (procedure Enact.Native.install_app
          (parameter path (type String))
          (failing argument_refused device_refused))
        
        (procedure Enact.Native.is_app_accessibility_enabled
          (returns Bool)
          (failing argument_refused device_refused))
        
        (procedure Enact.Native.launch_app
          (parameter bundle_id (type String))
          (parameter args (type (array String)))
          (parameter locale (type (optional String)))
          (parameter language (type (optional String)))
          (failing argument_refused device_refused))
        
        (procedure Enact.Native.long_press
          (parameter on (type Enact.Snapshot))
          (parameter at (type (optional Enact.Point)))
          (parameter duration (type Double))
          (failing argument_refused device_refused reference_unfit))
        
        (procedure Enact.Native.look
          (returns Enact.Screen)
          (failing argument_refused device_refused))
        
        (procedure Enact.Native.move_slider
          (parameter on (type Enact.Snapshot))
          (parameter value (type Double))
          (failing argument_refused device_refused reference_unfit))
        
        (procedure Enact.Native.nearest
          (const)
          (isolated)
          (parameter elements (type (array Enact.Snapshot)))
          (parameter to (type Enact.Point))
          (parameter screen (type Enact.Screen))
          (returns (array Enact.Snapshot))
          (failing argument_refused))
        
        (procedure Enact.Native.open_url
          (parameter url (type String))
          (failing argument_refused device_refused))
        
        (procedure Enact.Native.press_button
          (parameter button (type Enact.Button))
          (failing argument_refused device_refused))
        
        (procedure Enact.Native.press_key
          (parameter key (type String))
          (parameter modifiers (type (array Enact.Modifier)))
          (failing argument_refused device_refused))
        
        (procedure Enact.Native.push_notification
          (parameter bundle_id (type String))
          (parameter payload (type (dictionary String Any)))
          (failing argument_refused device_refused))
        
        (procedure Enact.Native.read_pasteboard
          (returns String)
          (failing argument_refused device_refused))
        
        (procedure Enact.Native.record
          (parameter name (type (optional String)))
          (parameter body (type (procedure (parameters) (failing (anything)) (returns (some Result)))))
          (returns (some Result))
          (failing (anything)))
        
        (procedure Enact.Native.record_log
          (parameter name (type (optional String)))
          (parameter predicate (type (optional String)))
          (parameter body (type (procedure (parameters) (failing (anything)) (returns (some Result)))))
          (returns (some Result))
          (failing (anything)))
        
        (procedure Enact.Native.repeat
          (parameter timeout (type Double))
          (parameter debounce (type (optional Double)))
          (parameter body (type (procedure (parameters) (failing (anything)) (returns (some Result)))))
          (parameter until (type (procedure (parameters (some Result)) (failing (anything)) (returns Bool))))
          (returns (some Result))
          (failing (anything)))
        
        (procedure Enact.Native.reset_keychain
          (failing argument_refused device_refused))
        
        (procedure Enact.Native.reset_privacy
          (parameter service (type (array Enact.PrivacyService)))
          (failing argument_refused device_refused))
        
        (procedure Enact.Native.respond_biometric
          (parameter outcome (type Enact.BiometricOutcome))
          (failing argument_refused device_refused))
        
        (procedure Enact.Native.screenshot
          (parameter name (type (optional String)))
          (returns String)
          (failing argument_refused device_refused))
        
        (procedure Enact.Native.set_appearance
          (parameter value (type Enact.Appearance))
          (failing argument_refused device_refused))
        
        (procedure Enact.Native.set_content_size
          (parameter value (type Enact.ContentSize))
          (failing argument_refused device_refused))
        
        (procedure Enact.Native.set_contrast
          (parameter value (type Enact.Contrast))
          (failing argument_refused device_refused))
        
        (procedure Enact.Native.set_location
          (parameter lat (type Double))
          (parameter lon (type Double))
          (failing argument_refused device_refused))
        
        (procedure Enact.Native.set_location_route
          (parameter route (type String))
          (failing argument_refused device_refused))
        
        (procedure Enact.Native.set_location_waypoints
          (parameter waypoints (type (array Enact.Coordinate)))
          (parameter speed (type (optional Double)))
          (failing argument_refused device_refused))
        
        (procedure Enact.Native.set_orientation
          (parameter value (type Enact.Orientation))
          (failing argument_refused device_refused))
        
        (procedure Enact.Native.set_pasteboard
          (parameter text (type String))
          (failing argument_refused device_refused))
        
        (procedure Enact.Native.set_privacy
          (parameter action (type Enact.PrivacyDecision))
          (parameter service (type (array Enact.PrivacyService)))
          (parameter bundle_id (type String))
          (failing argument_refused device_refused))
        
        (procedure Enact.Native.set_status_bar
          (parameter time (type (optional String)))
          (parameter data_network (type (optional Enact.DataNetwork)))
          (parameter wifi_mode (type (optional Enact.WifiMode)))
          (parameter wifi_bars (type (optional Int)))
          (parameter cellular_mode (type (optional Enact.CellularMode)))
          (parameter cellular_bars (type (optional Int)))
          (parameter operator_name (type (optional String)))
          (parameter battery_state (type (optional Enact.BatteryState)))
          (parameter battery_level (type (optional Int)))
          (failing argument_refused device_refused))
        
        (procedure Enact.Native.sleep
          (parameter sec (type Double))
          (parameter because (type String))
          (failing argument_refused))
        
        (procedure Enact.Native.swipe
          (parameter direction (type Enact.Direction))
          (parameter duration (type Double))
          (failing argument_refused device_refused))
        
        (procedure Enact.Native.swipe_between
          (parameter from (type Enact.Point))
          (parameter to (type Enact.Point))
          (parameter duration (type Double))
          (failing argument_refused device_refused))
        
        (procedure Enact.Native.swipe_on
          (parameter on (type Enact.Snapshot))
          (parameter direction (type Enact.Direction))
          (parameter duration (type Double))
          (failing argument_refused device_refused reference_unfit))
        
        (procedure Enact.Native.tap
          (parameter on (type Enact.Snapshot))
          (parameter at (type (optional Enact.Point)))
          (failing argument_refused device_refused reference_unfit))
        
        (procedure Enact.Native.tap_point
          (parameter at (type Enact.Point))
          (failing argument_refused device_refused))
        
        (procedure Enact.Native.terminate_app
          (parameter bundle_id (type String))
          (failing argument_refused device_refused))
        
        (procedure Enact.Native.type_text
          (parameter text (type String))
          (failing argument_refused device_refused))
        
        (procedure Enact.Native.unfold
          (failing argument_refused device_refused))
        
        (procedure Enact.Native.uninstall_app
          (parameter bundle_id (type String))
          (failing argument_refused device_refused))
        
        (procedure Enact.Native.within
          (const)
          (isolated)
          (parameter elements (type (array Enact.Snapshot)))
          (parameter in (type Enact.Snapshot))
          (returns (array Enact.Snapshot)))
        """
}

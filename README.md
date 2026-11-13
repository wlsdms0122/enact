# enact

Two things in one binary:

- **Scenarios.** Runs a procedure written in YAML (a scenario) on an iOS device,
  deterministically and with no LLM in the loop, and reports what happened.
- **Device control.** `enact device <op>` drives a device directly, one
  operation at a time (tap, describe-ui, record-video, …), through Digit, the
  same device-control module the scenarios stand on.

The language is not enact's own. A scenario is a [Warp](https://github.com/wlsdms0122/warp-runtime-swift)
module written in Warp's YAML notation ([warp-frontend-yaml](https://github.com/wlsdms0122/warp-frontend-yaml)),
the same language forge runs. enact lends it a vocabulary, the verbs that touch a
device, and keeps the record a device run needs. Everything the language does
that is not about a device is Warp's, and this document does not restate it.

**This document is the SSoT for design policy.** Code comments state facts about
the code; philosophy, policy and rationale live here. A rule not written here is
not a rule.

```
enact run <scenario> --udid <udid>     # perform. plain by default, --json for one JSON line
enact run … --input amount=1000        # an input of the scenario's main, read as its declared type
enact run … --verbose                  # every statement, not only the failures and what held them
enact run … --report                   # + the whole record as report.json in --out-dir
enact run … --stream                   # + journal events as NDJSON on stderr, live
enact run … --stop-at <address>        # carry out up to a statement and end there, e.g. login/name
enact check <scenario>                 # read and build only, no device: the same code as a run's first moment
enact graph <scenario>                 # what it calls, and what it can ask a device to do
enact device <op> --udid <udid>        # direct device ops (tap, describe-ui, …)
enact device stream-video --udid <udid> | ffplay -f h264 -
                                       # the screen live
enact device session --udid <udid>     # one device op per stdin line (tap --point 200,400), a JSON line back
enact draft --udid <udid> --output <draft.yaml>
                                       # a session whose operations are also written as a scenario draft
```

`<scenario>` is one of three spellings, told apart by shape, like a linker's
command line, where an object file is used as given and `-lfoo` is searched for:

- a **file path** (has a `/` or a `.yaml`/`.yml` ending) is used as given, never
  searched for, and runs as the name its text declares, or its file's name
  where it declares none.
- a **bare name** is the name a scenario declares, found in the search list,
  which is then required.
- `-` reads the text from stdin, and runs as a file does.

The search list, every `--path <dir>` in order, is where a bare name and a
called scenario are found, and nothing else is: the folder of a file run joins
it only as a `--path`. Every `.yaml` and `.yml` file under a root, in folders at
any depth, is a scenario found under the name its text declares, whatever the
file and its folders are called, so scenarios are arranged in folders as the
author likes and one `--path` names them all. A hidden file or folder is passed
over, a root that is no directory is refused, and a file reached from two roots,
or run and found under a root as well, is one scenario. A name two files
declare is refused where it is run or used, like a duplicate symbol: which
files a call graph reaches is the author's arrangement, fixed by what the files
declare, not by how the run was invoked. A refusal of a text names its file,
line and column.

## Building

The repository is an open-package: `manifest.toml` names what it can run, and
`open-package` with no command lists it.

```
open-package set-up          # bake idb's libraries into package/Frameworks, once per toolchain
open-package build           # package/.build/release/enact
open-package test
open-package embed-library   # after editing lib/
```

## What it is, and is not

enact is an **automation engine, not a test runner.** Checking is one use of it,
so:

- There is no `ok` in the report. It carries `outcome`
  (completed/aborted/refused) and a `failures` list, and success is defined by
  the reader: a macro succeeded if it completed, a check succeeded if `failures`
  is empty.
- Failures are not attributed. `StepFailure.kind` is the mechanical cause
  (timed_out, device_refused, …); whether that means "the ground was not laid"
  or "the app is wrong" is the reader's judgement.
- `graph` lists what a procedure can reach; it is not a risk assessment. A
  procedure that moves money is three taps, and no listing of operations will
  show that.

The engine **cannot control the screen, it only observes it.** The screen is
free to change between any two statements; every looping and judging verb stands
on that premise.

## Layers

```
Warp       the language: modules, statements, expressions, types, signatures,
           the build (compile, link) and the executor. Knows nothing of devices
Library    lib/Enact.yaml, the verbs a scenario writes, each one call of a native,
           and compositions that say with verbs what a scenario would
Natives    Enact.Native.*, the Swift procedures that drive the device, each
           taking and giving what lib/Native.interface.warpt declares, over the
           types lib/Enact.interface.warpt declares (Enact.Screen, Enact.Snapshot
           and the rest)
Engine     a scenario and the scenarios it calls, read and built over the library
           and the standard vocabulary, then run on one device
Journal    Warp's ExecutionObserver. The record, appended as it happens.
           Report = the journal, printed
Digit      device-control mechanism (no policy, separate module)
```

Digit has no policy in the sense that it reads nothing into what it returns: what
a tree, a state or a failure means, and what to do next, is the caller's. An
operation may still wait and try again for what it needs to finish itself: the
keys a software keyboard redraws or a hardware keyboard keeps away, an
accessibility read the service did not answer, application accessibility that is
off, a booted device whose screen does not answer yet. An app serves its
accessibility only while that setting is on, so a read of the screen turns it on
where it is off and leaves it on: a process started later, as a web view's
content, serves its elements too. A boot or a reboot returns once the screen
answers a read, since a device read too soon after it booted can stay unable to
name its frontmost app until it boots again.

The layers sit in modules, each knowing only the ones below it:

```
EnactCLI   enact: run, check, graph, and device (DigitCLI)
Enact      the engine and the journal: read, build, run, report
EnactWarp  the Warp extension: the natives, the library, and what a run lends
           them (the device, the out dir, the videos it landed)
Digit      device control
```

The seam is `Engine.run`: build the scenario, refuse what cannot run, take the
device and hold it for the whole run, hand the image to Warp's executor, and turn
what comes back into a report.

## A scenario

A scenario is a module. It declares its `name`, writes the modules it uses
under `uses:` (`Enact`, the verbs and their types, and any scenario it calls),
and a run starts from its public procedure called `main`, whose parameters are
the scenario's inputs. One with no `main` is a module other scenarios call:
`enact check` builds it, and a run refuses it.

```yaml
name: Transfer
uses: [Enact]
procedures:
  main:
    access: public
    parameters:
      - app: { type: String, default: "com.example.app" }
      - account: String
      - pin: String?
    returns: String
    failing: anything
    body:
      - let: open
        value: { call: { procedure: launch_app, arguments: { bundle_id: { ref: app } } } }
      - let: seen
        value: { call: { procedure: look } }
      - let: send
        value: { call: { procedure: tap, arguments: { on: { ref: "seen.elements[3]" } } } }
    result: { ref: account }
```

Every statement is Warp's: `let`, `var`, `set` and `value`, with expressions,
operators, `cases`, `each`, `loop`, `try` and closures as the
[notation](https://github.com/wlsdms0122/warp-frontend-yaml) spells them. A
statement's name is the last segment of its address in the record; a statement
written with no name is addressed by its position, `[2]`.

A procedure declares what it may fail with. A scenario that calls device verbs
writes `failing: anything` or lists the kinds it lets through, and the build
refuses one that says less than what it calls.

### Calling another scenario

A scenario calls another through the name the other declares, and uses it as
the module of that name:

```yaml
name: Checkout
uses: [Enact, Login]
procedures:
  main:
    access: public
    failing: anything
    body:
      - let: signIn
        value: { call: { procedure: Login.main, arguments: { user: me } } }
```

`Login.main` reaches the scenario in the search list that declares
`name: Login`, whatever its file is called and wherever under a root it is.
Every scenario the search list finds is a module the caller may use, so a call
names its arguments as any call does, and the build refuses a name, an argument
or a type that does not fit. A text that does not read, or declares no name, is
no module, and is refused where something calls it. A name two scenarios
declare is refused where a scenario uses it.

### Looking: `look`

`look()` reads the screen once and returns an `Enact.Screen`: its `width` and
`height`, and every element on it as an `Enact.Snapshot`, in reading order, each
before the elements inside it.

```yaml
- let: seen
  value: { call: { procedure: look } }
- let: rows
  value:
    of: { ref: seen.elements }
    filter: { closure: { parameters: [ one: Enact.Snapshot ], result: { of: { ref: one.label }, is: "보내기" } } }
- let: lower
  value: { call: { procedure: in_area, arguments: { elements: { ref: rows }, area: { struct: { x: 0, y: 0.5, width: 1, height: 0.5 } }, screen: { ref: seen } } } }
```

**A look is an act, the questions are arithmetic.** A look costs what it costs
(about a second on an iOS 26 simulator, 0.7 to 1.4s measured, more for a deeper
tree); asking it many questions costs nothing more, and two looks are two acts
at two moments. The questions are Warp's own collection operators
(`filter`, `first`, `count`, …) and three procedures of the library, each pure:

- `within(elements, in)` keeps what sits inside a container of the same look, at
  any depth, as the tree the look read says.
- `in_area(elements, area, screen)` keeps what meets an area of the screen,
  given as fractions of its width and height.
- `nearest(elements, to, screen)` orders by the distance from the middle of each
  to a point of the screen, the nearest first.

What another process draws inside the app, as a web view's content, is not in
the app's tree and answers only a press at a point. A look finds it by pressing
at points 100 apart, and where it finds any, again at points 20 apart (about two
seconds more than a look elsewhere). Each element found that way follows the
app's own elements, in rows from the top, with none inside another; one smaller
than the grid can be missed. SpringBoard's status bar is left out.

A snapshot is `{ id, label, value, role, enabled, actions, frame, track, index_path }`.
`frame` and `track` (a slider's rail) are `Enact.Frame`s in points; `index_path`
is where the element sits in the tree. **A question about nothing is an empty
list, not a failure.**

A closure over snapshots writes its parameter's type (`one: Enact.Snapshot`):
untyped, a parameter reads as `Any`, which has no fields to read.

Which field holds an element's text depends on what the element is: a field's
text is its `value`, and its `label` names it; anything else's text is its
`label`. `displayed_text(of)` reads the one its role shows, and the empty text
where that is none.

Waiting for an element is common enough that the library composes it:
`wait_for` looks until an element `where` holds of is on the screen and stays
put for `debounce` seconds (0.5 by default, so it is not caught mid
animation), and returns the first in reading order. Past `timeout` (10 by
default) it is `timed_out`.

```yaml
- let: save
  value: { call: { procedure: wait_for, arguments: { where: { closure: { parameters: [ one: Enact.Snapshot ], result: { of: { ref: one.label }, is: Save } } } } } }
- let: press
  value: { call: { procedure: tap, arguments: { on: { ref: save } } } }
```

### Failure: `try`

A failure a statement can recover from is a `StepFailure` whose kind is its
Warp failure type, so a `try` takes it and the catch reads the kind:

```yaml
- var: outcome
  type: String
  value: sent
- let: failure
  value:
    try:
      body:
        - value: { call: { procedure: tap, arguments: { on: { ref: "rows[0]" } } } }
      catch:
        - set: outcome
          value: { ref: failure.type }
```

- The record still says the statement **failed**, because it did. What a caught
  failure gives up is its claim on `failures`, the list a verdict is read from.
- An interruption (Ctrl-C, a stop) is a cancellation, not a failure, and no
  catch takes it.

### Device verbs

`lib/Enact.yaml` is the SSoT for spelling: each verb's parameters, their types
and defaults, and what it may fail with. Each verb is one call of the native of
its name (`tap` calls `Enact.Native.tap`). A composition calls verbs and never a
native, so it says nothing a scenario could not say itself.

| verb | arguments |
|---|---|
| `tap` | `on: Enact.Snapshot`, `at: Enact.Point?` |
| `tap_point` | `at: Enact.Point` (a fraction of the screen) |
| `long_press` | `on`, `at?`, `duration = 0.5` |
| `type_text` | `text` |
| `move_slider` | `on: Enact.Snapshot`, `value` (a fraction of the rail) |
| `press_key` | `key` (a character or a key's name), `modifiers = []` |
| `press_button` | `button` |
| `swipe` | `direction`, `duration = 0.2` |
| `swipe_on` | `on: Enact.Snapshot`, `direction`, `duration = 0.2` |
| `swipe_between`, `drag` | `from: Enact.Point`, `to: Enact.Point`, `duration = 0.2` |
| `respond_biometric` | `outcome = "match"` |
| `launch_app` | `bundle_id`, `args = []`, `locale?`, `language?`; an app already running is launched anew. It returns once the process starts, and until the app draws, a look reads the app that was in front or none of this one; `app_state` tells whether it is in front yet |
| `terminate_app`, `uninstall_app` | `bundle_id` |
| `app_state` | `bundle_id`, returns an `Enact.AppState`: `notRunning`, `background`, or `foreground`, the app the screen shows. It reads which app that is as a look does |
| `install_app` | `path` |
| `open_url` | `url` |
| `push_notification` | `bundle_id`, `payload`: the APNs payload as a dictionary, `{ dictionary: { aps: { dictionary: { alert: Hi } } } }` |
| `set_appearance`, `set_content_size`, `set_contrast` | `value` |
| `set_privacy` | `action` (grant, revoke, reset), `service: [ … ]` (each service `simctl privacy` takes, `all` among them, and `camera`), `bundle_id` |
| `reset_privacy` | `service: [ … ]`, every app |
| `set_location` | `lat`, `lon` |
| `set_location_route` | `route` |
| `set_location_waypoints` | `waypoints: [ … ]` (two or more `Enact.Coordinate`, `{ struct: { lat: 37.5, lon: 127 } }`), `speed?` in metres per second |
| `clear_location`, `clear_status_bar` | none |
| `set_orientation` | `value: Enact.Orientation` |
| `fold`, `unfold` | none |
| `connect_hardware_keyboard`, `disconnect_hardware_keyboard` | none |
| `is_app_accessibility_enabled` | none, returns whether application accessibility is on |
| `enable_app_accessibility`, `disable_app_accessibility` | none; a read of the screen turns it on where it is off, and apps already serving their elements keep serving them after it is turned off |
| `set_status_bar` | `time?`, `data_network?`, `wifi_mode?`, `wifi_bars?`, `cellular_mode?`, `cellular_bars?`, `operator_name?`, `battery_state?`, `battery_level?` |
| `add_media` | `paths: [ … ]` |
| `add_certificate`, `add_root_certificate` | `path`, a certificate file; a root is trusted, as a proxy's certificate is |
| `reset_keychain` | none; a certificate trusted as a root stays until the device is erased |
| `set_pasteboard` | `text`; `device_refused` where the pasteboard does not read it back |
| `read_pasteboard` | none, returns the text |
| `screenshot` | `name?`, returns where it was saved |
| `element_at` | `at: Enact.Point` (a fraction of the screen), returns the snapshot a press there lands on, or none; its `index_path` is empty, as it stands in no look |

| composition | arguments |
|---|---|
| `displayed_text` | `of: Enact.Snapshot`, returns a field's `value`, a heading's or a text's `label` or its `value` where the label is empty, or anything else's `label`; the empty text where that is none |
| `screen_point` | `on: Enact.Snapshot`, `at: Enact.Point` (fractions of its frame, outside 0 to 1 for beside it), `screen: Enact.Screen`, returns the point as fractions of the screen, for `element_at` and `tap_point` |
| `paste_text` | `text`: `set_pasteboard`, then command-V. For text no key types; what was on the pasteboard is replaced |
| `clear_text` | none: command-A, then delete once, which leave the software keyboard up. A field that keeps command-A from selecting loses only the character before the caret; whether it is empty is read from a look |
| `wait_for` | `where`, `timeout = 10`, `debounce = 0.5`, returns the snapshot |
| `scroll_to` | `where`, `on` (what to swipe in), `direction` (the way the content moves), `timeout = 30`, `debounce = 0.5`: `swipe_on` each round `where` holds of nothing on the screen, returns the snapshot |

A verb whose parameters are all defaulted or optional, or that has none, is
called with no `arguments`.

`type_text` types on the software keyboard on the screen, into whatever it types
into, so a scenario taps the field first. It taps for each character the key
labeled with it, in whichever keyboards the device has: the layers and keyboards
that have a key are found by tapping shift, the number key and Next keyboard.
Korean is spelled with the keys of the two-set keyboard. A return and a tab are
hardware key presses. A connected hardware keyboard keeps the software keyboard
away, so a scenario that types disconnects it first with
`disconnect_hardware_keyboard`; nothing says whether one is connected. With no
software keyboard on the screen the step fails, as it does where a device's
first software keyboard is still behind its introduction, until its `Continue`
is tapped. A keyboard that comes up a moment after the tap is waited for as any
element is, its keys being snapshots whose role is `key`:

```yaml
- value: { call: { procedure: wait_for, arguments: { where: { closure: { parameters: [ one: Enact.Snapshot ], result: { of: { ref: one.role }, is: { case: key } } } } } } }
- value: { call: { procedure: type_text, arguments: { text: "123456" } } }
```

Every character is found on a key before the first is typed, and a character no
keyboard of the device has is refused, typing nothing; so is a jamo the keyboard
would compose into the character before it, as `ㅋ` after `가`. A tap that leaves
every field as it was fails the call. Some fields are not in the app's own tree,
which the typing reads, as a web page's: where the first tap changes no field
there, the taps are made without that check, and a scenario that needs the text
checks it with `wait_for`. The keyboard is left on the one it was found on. What the
keyboard itself does with the keys stays, as a period for two spaces. A tap per
key is slow; `paste_text` is the fast way, and the way for the rest.

`set_orientation` turns the device, and the interface follows where the app
turns with it, so a scenario waits for what it expects to see. `fold` and
`unfold` return once the screen the hinge brings up is on, and a device that
does not fold refuses them as `device_refused`. A look reads every element
where the screen shows it, whichever way the screen is turned.

A press lands where the screen shows what was aimed at, or not at all: `tap`
and `long_press` on a disabled snapshot, or at a point off the screen, are
`reference_unfit`, and `swipe_on` swipes across the part of its snapshot the
screen shows. `tap_point` is for what no look can name, and `element_at` reads
what a press at a point would land on. What no look names often stands beside
what one does, as a menu shown under a field; `screen_point` gives that point
from the field.

**A sentence is a verb.** Where one verb used to take one of several key
combinations, each combination is a verb of its own (`swipe` and
`swipe_between`, `set_location` and `clear_location`), so the build refuses an
incomplete sentence instead of a run discovering it.

A point is an `Enact.Point`, `{ struct: { x: 0.88, y: 0.5 } }`, each coordinate a
fraction from 0 to 1. `tap`'s `at` is a fraction of the *element*; `tap_point`'s
`at` and a stroke's `from`/`to` are fractions of the *screen*. `screen_point`'s
`at` is the one that may leave 0 to 1, since it names a place beside an element
and presses nothing.

A word (a direction, a button, an appearance, an orientation, a privacy service,
a status bar's network, mode or battery state, a snapshot's role) is a case of
the enum that names its set (`Enact.Direction`, `Enact.Button`, …), written as a
case literal, `{ case: up }`. A case is named as the word in lower camel case
(`applePay`, `extraLarge`), and the build refuses a word its set does not have.
An input to a run names the case alone (`--input way=up`). A key's name is text,
written in any case with spaces or underscores for hyphens, and a key the
keyboard does not have is refused when the verb runs, with the keys there are.

### `repeat`, `record`, `record_log`, `sleep`

```yaml
- let: shown
  value:
    call:
      procedure: repeat
      arguments:
        timeout: 10
        debounce: 0.5
        body: { closure: { returns: Enact.Screen, result: { call: { procedure: look } } } }
        until: { closure: { parameters: [ screen: Enact.Screen ], result: { of: { count: { ref: screen.elements } }, greater_than: 3 } } }
- let: recorded
  value: { call: { procedure: record, arguments: { name: walk, body: { closure: { returns: Int, result: 1 } } } } }
- let: logged
  value: { call: { procedure: record_log, arguments: { name: walk, predicate: 'process == "Preferences"', body: { closure: { returns: Int, result: 1 } } } } }
- let: rest
  value: { call: { procedure: sleep, arguments: { sec: 1.5, because: "시트가 올라올 틈" } } }
```

- `repeat` runs its body round after round until `until` holds of what a round
  returned, and returns it. With `debounce`, what held must come back the same
  for that long. Past `timeout` it is `timed_out`.
- `record` is a span, not a pair of handles: a recording lives only in the
  connection that opened it, so the body runs inside it and the video closes
  when the body is done, however it went. It returns what the body returned,
  and the video lands in `--out-dir` and in the report's `recordings` even when
  the body failed, since a failed run is the one a video is wanted for. A video
  the recorder could not close is in the report's `lostRecordings` with why,
  not in `recordings`, and leaves no empty file in `--out-dir`: under a body
  that went well it is `recording_failed`;
  under a failed body, the body's failure goes on as it was. A video that could
  not start runs no body and is `recording_failed`. One video per device is
  Digit's contract, so a `record` inside a `record` is `recording_failed` when
  it runs.
- `record_log` is the same span over the device's unified log: what
  `log stream` prints while the body runs, only the lines `predicate` holds of
  where it is given, lands as a `.log` file in `--out-dir` and in the report's
  `recordings`, and a predicate `log stream` cannot parse is
  `recording_failed`. A log streams beside a video and beside another log, so it
  runs inside a `record` or a `record_log`.
- `sleep` says why. A wait with no reason is refused.

## Policy

### Refusal: what is not known is refused

Unknown names, missing arguments and wrong types are refused by the build,
before a device is touched. Each refusal names the scenario and the line and
column of its text, `typo:9:61: sending 'Enact.type_text' with text, which holds
Int where String is declared`. The grounds are three real incidents where silently
dropped input reported "success" every time:

1. `privacy: {bundle_ids: …}` read as no bundle at all, **granted the permission
   to every app on the device**, then ok
2. `element_type: Buton` made the predicate vanish, tapped some other element,
   then ok
3. `stpes:` ran zero steps to completion, then ok

A signature is the place a verb's arguments are judged, and a native does not
judge them again. What a signature cannot say is a fact about a value, and the
verb refuses it when it runs: a key the keyboard does not have, a point outside
0 to 1, a negative wait. `enact check` is the front of a run, not a second checker.

### Reporting: the journal is the record

- The journal is Warp's `ExecutionObserver`. It appends as the run goes:
  `run_begin` / `step_begin` / `step_end` / `run_end`. The report is the journal
  printed: a run that dies part way still has every statement it got through.
  `--stream` is the same journal, live (NDJSON on stderr; stdout stays the
  report's).
- **The record is the scenario's statements.** A statement is recorded when the
  body it stands in is the scenario's (its procedures and closures), so a verb's
  own statements in the library stay out. A statement holds the statements that
  ran under it, through the procedures and verbs it called, and its `kind` is the
  procedure it called by its qualified name, `Enact.tap` or `Login.main`. An address is the recorded statements' names joined with
  `/`, the trace Warp hands the observer read down to the scenario's own.
- A failure is **charged where it happened**: address, evidence (screenshot and
  tree, taken once) and the `failures` entry. The statements it travels out
  through say `failed` and no more.
- Rounds: the statements a `repeat` round or a Warp loop ran are written under
  that round.
- Failure kinds: `timed_out` · `device_refused` · `argument_refused` ·
  `reference_unfit` · `recording_failed` · `interrupted` · `aborted`. A kind is
  something a consumer branches on. Warp's `abort` is `aborted` and a refused
  cast is `reference_unfit`.
- `result` is what `main` returned, for a run that finished, as JSON: a struct
  as an object of its fields, and a value of an enum as an object of its case
  alone, holding what it carries (`{"up":{}}`).
- `recordings` are the videos a run kept; `lostRecordings` the videos it could
  not close, each with its path and why.

### Execution

- The capability pre-flight walks **everywhere the program can reach**, not only
  the path that certainly runs. A capability is a fact about the program the way
  a type is: a verb that could not work if reached is a defect whether or not
  this run arrives at it.
- **`--stop-at` is observed, not asked for.** The journal watches for the
  address, cancels the run when it sees it, and the runner tells that
  cancellation from a real one by the journal having seen it. A bounded run is
  `completed` with `stop: { at, reached }`, and keeps no result. An address
  the scenario's statement tree does not have is refused before the run, with
  the addresses of the statements it names; one the run never arrives at is
  reported as never reached.
- The device is held for the whole run: a scenario is one sequence, and it is
  not one if someone else's tap can land in the middle of it. A device already
  held is reported busy rather than waited for.
- The device is an argument of the run. A scenario does not know its device,
  only the app it talks to, which it is handed like any other input.
- The verb table grows exactly as Digit grows. describe-ui (the means of every
  look), describe-screen (what a screen fraction is a fraction of), record-video
  and record-log (the `record` and `record_log` spans), stream-video (watching is not a step of a scenario),
  session (a run already holds its device) and device lifecycle are not verbs. The device set is
  managed from `enact device`: `create`, `clone` and `delete` add and remove
  devices, and `boot`, `shutdown`, `reboot` and `erase` act on one.
- An app's logged-in state is kept as a device, not as a verb. The keychain is
  one database for the whole device, so one app's login cannot be lifted out
  of it alone. A device logged in once and then shut down is cloned for each
  run, which takes seconds:

  ```sh
  enact device clone --udid <logged-in> --name run-1
  ```
- There are no cleanup steps. What must survive a failure belongs to the caller.
- `enact device session` drives a device one command at a time through one
  held connection, since each `enact device` command opens the device anew.
  Its lines are commands as `enact device` spells them, each answered by one
  line of JSON, and it carries every command that does one thing to a device.
  A failed line answers `{"error": {"kind", "detail"}}`, its kind
  `argument_refused` when the line is at fault and `device_refused`
  otherwise, the words a scenario's failed steps use.
  Its standard input is its lines, so text a command would read with `-` is
  written on the line.
  It takes no lock, and neither does `stream-video`, which only shows the
  screen, so both run beside a scenario, a recording and each other. A line
  sent during a run lands in the middle of the run's sequence; keeping the two
  apart is the caller's.
- `enact draft` is a session that also writes what it does as a scenario:
  the same lines and answers, and each line that does something to the device
  becomes a statement of the draft's `main`, by the verb that does the same.
  Reads, refused lines and failed lines are not written, and what no verb does
  is a comment. Composing scenarios is Enact's, so it stands beside `run`, not
  under `device`; `record` already names recording. A press is named by what the
  library's own `look` and `element_at` read under it before it is done, so
  what the draft waits for is what a run catches: a `wait_for` by the first of
  the label, the identifier, and the role and `displayed_text` that catches it
  alone, then the verb on what it returns. What no look names is a `tap_point`, checked by `element_at`
  where it answers, with a comment to confirm what is there where it does not.
  An element as large as the screen names no press, and where no catch holds
  of it alone, the first one is written with a comment saying which one was
  pressed. The look before the next
  line is the screen the press led on to; what it newly shows (a heading, else
  a field or a button, else a text, never the keyboard) is waited for after
  the press. A just launched app's elements are read only seconds later, so a
  press sent at once gets a comment in place of a wait. The file is written
  again after every line, so it runs at any moment, and it is a draft: what it
  presses and waits for are what one walk saw, for a person to edit.

  ```sh
  { echo "launch-app --bundle-id com.apple.Preferences"; sleep 8; echo "tap --point 201,406"; } |
    enact draft --udid <udid> --output settings-walk.yaml
  ```

  ```yaml
  name: SettingsWalk
  uses: [Enact]
  procedures:
    main:
      access: public
      failing: anything
      body:
        - value: { call: { procedure: launch_app, arguments: { bundle_id: "com.apple.Preferences" } } }
        - let: generalButton
          value: { call: { procedure: wait_for, arguments: { where: { closure: { parameters: [ { one: Enact.Snapshot } ], result: { of: { ref: one.label }, is: "General" } } } } } }
        - value: { call: { procedure: tap, arguments: { on: { ref: generalButton } } } }
  ```
- Waiting is not a command. What counts as there, and for how long, is a
  scenario's, so a wait from the shell is a scenario on stdin:

  ```sh
  enact run - --udid <udid> <<'EOF'
  name: Wait
  uses: [Enact]
  procedures:
    main:
      access: public
      failing: anything
      body:
        - value: { call: { procedure: wait_for, arguments: { where: { closure: { parameters: [ one: Enact.Snapshot ], result: { of: { ref: one.label }, is: Send } } }, timeout: 5 } } }
  EOF
  ```

## The library

`lib/` is embedded in the binary by `tool/embed-library.sh`, which writes
`package/Sources/EnactWarp/Vocabulary/Library.swift`. A test holds the two to the
same texts, so a file edited without running the script is a red test.

- `Enact.yaml`, the library. Its verbs and the types beside it are the module
  `Enact` a scenario uses.
- `Enact.interface.warpt`, the types the natives module declares, and
  `Native.interface.warpt`, its natives, the module `Native` only the library
  uses. Each native is named as the verb that calls it, so a scenario using it
  would read every verb as two. The natives module is made from the two
  files: a native takes, gives and fails as its declaration says, and its
  Swift names only where it reads each argument, which the module refuses
  where it differs from the declaration.

//
//  Element+Snapshot.swift
//  Digit
//
//  Created by JSilver on 11/13/26.
//

import FBSimulatorAX
import Foundation

extension Element {
    // MARK: - Property
    // XCUIElementType's cases by raw value, spelled as the accessibility tree names an
    // element's type.
    private static let types = [
        "Any", "Other", "Application", "Group", "Window", "Sheet", "Drawer", "Alert", "Dialog", "Button",
        "RadioButton", "RadioGroup", "CheckBox", "DisclosureTriangle", "PopUpButton", "ComboBox",
        "MenuButton", "ToolbarButton", "Popover", "Keyboard", "Key", "NavigationBar", "TabBar",
        "TabGroup", "Toolbar", "StatusBar", "Table", "TableRow", "TableColumn", "Outline", "OutlineRow",
        "Browser", "CollectionView", "Slider", "PageIndicator", "ProgressIndicator", "ActivityIndicator",
        "SegmentedControl", "Picker", "PickerWheel", "Switch", "Toggle", "Link", "Image", "Icon",
        "SearchField", "ScrollView", "ScrollBar", "StaticText", "TextField", "SecureTextField",
        "DatePicker", "TextView", "Menu", "MenuItem", "MenuBar", "MenuBarItem", "Map", "WebView",
        "IncrementArrow", "DecrementArrow", "Timeline", "RatingIndicator", "ValueIndicator",
        "SplitGroup", "Splitter", "RelevanceIndicator", "ColorWell", "HelpTag", "Matte", "DockItem",
        "Ruler", "RulerMarker", "Grid", "LevelIndicator", "Cell", "LayoutArea", "LayoutItem", "Handle",
        "Stepper", "Tab", "TouchBar", "StatusItem"
    ]
    
    // MARK: - Initializer
    // An element of the test daemon's snapshot, read the way a describe-ui element is:
    // its role from the same traits, an empty label or identifier as none.
    init(snapshot: NSObject) {
        let type = (snapshot.value(forKey: "elementType") as? NSNumber)?.intValue
        let traits = (snapshot.value(forKey: "traits") as? NSNumber)?.uint64Value ?? 0
        let frame = (snapshot.value(forKey: "frame") as? NSValue)?.rectValue ?? .zero
        
        self.init(
            id: Self.text(snapshot.value(forKey: "identifier")),
            label: Self.text(snapshot.value(forKey: "label")),
            value: Self.text(snapshot.value(forKey: "value")),
            role: Role(traits: AXExtractTraits(traits), type: type.flatMap { type in Self.types.indices.contains(type) ? Self.types[type] : nil }),
            frame: Frame(x: frame.origin.x, y: frame.origin.y, width: frame.size.width, height: frame.size.height),
            enabled: (snapshot.value(forKey: "enabled") as? NSNumber)?.boolValue ?? true,
            actions: [],
            children: (snapshot.value(forKey: "children") as? [NSObject] ?? []).map(Element.init(snapshot:))
        )
    }
    
    // MARK: - Private
    private static func text(_ value: Any?) -> String? {
        let text =
            switch value {
            case let string as String: string
            case let number as NSNumber: number.stringValue
            default: String?.none
            }
        
        return text?.isEmpty == false ? text : nil
    }
}

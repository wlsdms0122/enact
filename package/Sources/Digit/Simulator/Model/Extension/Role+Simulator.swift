//
//  Role+Simulator.swift
//  Digit
//
//  Created by JSilver on 8/16/26.
//

import Foundation

extension Role {
    init(traits: [String], type: String?) {
        let has = { (trait: String) in traits.contains(trait) }
        
        if has("SecureTextField") {
            self = .secureField
            
            return
        }
        
        if has("TextEntry") || has("SearchField") || has("TextArea") || has("IsEditing") {
            self = .field
            
            return
        }
        
        if has("KeyboardKey") || has("DeleteKey") {
            self = .key
            
            return
        }
        
        if has("Link") || has("Visited") {
            self = .link
            
            return
        }
        
        if has("Toggle") {
            self = .toggle
            
            return
        }
        
        if has("Adjustable") {
            self = .slider
            
            return
        }
        
        if has("PickerElement") {
            self = .picker
            
            return
        }
        
        if has("Button") || has("PopupButton") || has("RadioButton") || has("TabButton")
            || has("BackButton") || has("MenuItem") || has("LaunchIcon") || has("FolderIcon") {
            self = .button
            
            return
        }
        
        if has("Alert") {
            self = .alert
            
            return
        }
        
        if has("TabBar") || has("StatusBarElement") {
            self = .bar
            
            return
        }
        
        if has("Map") {
            self = .map
            
            return
        }
        
        if has("WebContent") {
            self = .web
            
            return
        }
        
        if has("Image") {
            self = .image
            
            return
        }
        
        if has("Header") || has("Footer") {
            self = .heading
            
            return
        }
        
        if has("StaticText") {
            self = .text
            
            return
        }
        
        switch type {
        case "StaticText", "Text":
            self = .text
        
        case "Heading":
            self = .heading
        
        case "Image":
            self = .image
        
        case "Slider":
            self = .slider
        
        case "TextField":
            self = .field
        
        case "SecureTextField":
            self = .secureField
        
        case "Button":
            self = .button
        
        case "Link":
            self = .link
        
        case "Switch", "Toggle":
            self = .toggle
        
        case "ProgressIndicator", "ActivityIndicator":
            self = .progress
        
        case "Alert", "Sheet", "Dialog", "Popover":
            self = .alert
        
        case "NavigationBar", "TabBar", "Toolbar", "StatusBar":
            self = .bar
        
        case "Map":
            self = .map
        
        case "WebView":
            self = .web
        
        case "Key", "Keyboard":
            self = .key
        
        case "Picker", "PickerWheel", "DatePicker":
            self = .picker
        
        case "Application", "Group", "Window", "Other", "ScrollView", "ScrollArea", "Table",
            "CollectionView", "Cell", "TableRow", "Outline", "SplitGroup", "LayoutArea",
            "LayoutItem", "TabGroup", "Grid":
            self = .container
        
        case "GenericElement":
            self = .text
        
        default:
            self = .unknown
        }
    }
}

//
//  PrivacyService.swift
//  Digit
//
//  Created by JSilver on 8/16/26.
//

import Foundation

// The services `simctl privacy` takes, each spelled as it takes them. It
// takes `camera` too, which its help leaves out.
public enum PrivacyService: String, Sendable, CaseIterable {
    case all
    case calendar
    case camera
    case contactsLimited = "contacts-limited"
    case contacts
    case location
    case locationAlways = "location-always"
    case photosAdd = "photos-add"
    case photos
    case mediaLibrary = "media-library"
    case microphone
    case motion
    case reminders
    case siri
}

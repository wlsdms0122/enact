//
//  AccessibilityDocumentElement+RemoteContent.swift
//  Digit
//
//  Created by JSilver on 11/11/26.
//

import FBSimulatorAX
import Foundation

extension AccessibilityDocumentElement {
    // Remote content is what a press at a point found in another process, not what
    // the walk of the read application's tree found.
    var holdsRemoteContent: Bool {
        (isRemote ?? nil) == true || (children ?? []).contains(where: \.holdsRemoteContent)
    }
    
    func removingRemoteContent(of process: Int64?) -> AccessibilityDocumentElement {
        var element = self
        element.children = children?
            .filter { child in !((child.isRemote ?? nil) == true && (child.pid ?? nil) == process) }
            .map { child in child.removingRemoteContent(of: process) }
        
        return element
    }
}

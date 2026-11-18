//
//  AccessibilityDocumentElement+Silence.swift
//  Digit
//
//  Created by JSilver on 11/2/26.
//

import FBSimulatorAX
import Foundation

extension AccessibilityDocumentElement {
    // An application whose accessibility server is not running is still named by the
    // simulator, but reports no frame and no children of its own.
    var isSilentApplication: Bool {
        let size = self.frame ?? nil
        
        return (type ?? nil) == "Application"
            && (children ?? []).isEmpty
            && (size?.width ?? 0) == 0
            && (size?.height ?? 0) == 0
    }
}

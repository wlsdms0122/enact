//
//  EnactVocabulary+Testing.swift
//  EnactTests
//
//  Created by JSilver on 10/31/26.
//

import Foundation
@testable import EnactWarp

extension EnactVocabulary {
    static let shipped = Result { try EnactVocabulary() }
}

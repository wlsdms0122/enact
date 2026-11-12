//
//  ScenarioBuilder+Testing.swift
//  EnactTests
//
//  Created by JSilver on 10/31/26.
//

import Foundation
@testable import Enact
@testable import EnactWarp

extension ScenarioBuilder {
    static let shipped = EnactVocabulary.shipped.map { vocabulary in ScenarioBuilder(vocabulary: vocabulary) }
}

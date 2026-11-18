//
//  ScreenQuery.swift
//  Enact
//
//  Created by JSilver on 11/13/26.
//

import EnactWarp
import Foundation
import Warp

// A public, const and isolated procedure of one `Enact.Screen`, which asks
// nothing of a device and so answers of a screen written down as well as of
// one a look reads.
public struct ScreenQuery: Sendable {
    // MARK: - Property
    public let name: String
    
    private let image: Image
    private let entry: Warp.Name
    private let parameter: Warp.Name
    
    // MARK: - Initializer
    init(named name: String, in scenario: Scenario) throws {
        let entry = try Warp.Name(name)
        
        guard let procedure = scenario.procedures[entry], procedure.access == .public else {
            throw QueryRefused("\(scenario.name) declares no public procedure \(name)")
        }
        
        let signature = procedure.signature
        
        guard signature.constness == .const,
            signature.isolation == .isolated,
            signature.parameters.count == 1,
            case let .named(type, _) = signature.parameters[0].type,
            type == EnactVocabulary.screenType
        else {
            throw QueryRefused(
                "\(name) is no query of a screen: a const, isolated procedure of one \(EnactVocabulary.screenType)"
            )
        }
        
        self.name = name
        self.image = scenario.image
        self.entry = entry
        self.parameter = signature.parameters[0].name
    }
    
    // MARK: - Public
    // What the query answers of the screen a look read.
    func answer(of look: Look) async throws -> ReportedValue {
        let value = try await Executor().run(image, entry: entry, arguments: [parameter: try look.value])
        let enums = Set(image.types.types.compactMap { declared, type -> Warp.Name? in
            guard case .enum = type else { return nil }
            
            return declared
        })
        
        return ReportedValue(value, enums: enums)
    }
    
    // MARK: - Private
}

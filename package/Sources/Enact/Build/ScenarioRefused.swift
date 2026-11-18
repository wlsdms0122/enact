//
//  ScenarioRefused.swift
//  Enact
//
//  Created by JSilver on 11/5/26.
//

import Foundation
import Warp
import WarpYAML

// Scenario texts refused by the front end or by the build, each refusal at
// the file and the line and column of its text, the way a compiler names
// them. A refusal the build makes of the vocabulary stands in no file and
// reads as the build wrote it.
public struct ScenarioRefused: Error, CustomStringConvertible {
    public struct Refusal: Sendable, CustomStringConvertible {
        // MARK: - Property
        public let file: String?
        public let position: Origin.Position?
        public let message: String
        
        public var description: String {
            switch (file, position) {
            case let (file?, position?):
                "\(file):\(position): \(message)"
            
            case let (file?, nil):
                "\(file): \(message)"
            
            case (nil, _):
                message
            }
        }
        
        // MARK: - Initializer
        init(file: String, refused: AuthoringError) {
            self.file = file
            self.position = refused.position
            self.message = refused.message
        }
        
        // A refusal of the document a text was spent into, at the spot of the
        // text its place reads back to, and the private procedures it names
        // spelled as the text wrote them. Where the place reads back to no
        // spot, the message keeps the place the build wrote.
        init(file: String?, refused: any WarpError, origin: Origin?) {
            let position = refused.place.flatMap { place in origin?.position(of: place) }
            let message = position == nil ? refused.description : refused.message
            
            self.file = file
            self.position = position
            self.message = origin?.demangled(message) ?? message
        }
        
        // MARK: - Public
        // MARK: - Private
    }
    
    // MARK: - Property
    public let refusals: [Refusal]
    
    public var description: String {
        refusals.map(\.description).joined(separator: "\n")
    }
    
    // MARK: - Initializer
    init(file: String, refused: TextRefused) {
        self.refusals = refused.refusals.map { refusal in Refusal(file: file, refused: refusal) }
    }
    
    // Every refusal of one scenario's document.
    init(file: String, refused: any WarpError, origin: Origin) {
        self.refusals = Self.each(of: refused).map { refusal in
            Refusal(file: file, refused: refusal, origin: origin)
        }
    }
    
    // Each refusal of a build at the file of the document its place is in.
    init(_ refused: any WarpError, among documents: [String: ScenarioDocument]) {
        self.refusals = Self.each(of: refused).map { refusal in
            let found = refusal.place.flatMap { place in
                documents.values.first { document in
                    Place.Document.of(document.module).identity == place.document.identity
                }
            }
            
            return Refusal(file: found?.file, refused: refusal, origin: found?.origin)
        }
    }
    
    // MARK: - Public
    // MARK: - Private
    // A build refuses with every refusal it reached, each at its own place.
    private static func each(of refused: any WarpError) -> [any WarpError] {
        (refused as? BuildRefused)?.refusals ?? [refused]
    }
}

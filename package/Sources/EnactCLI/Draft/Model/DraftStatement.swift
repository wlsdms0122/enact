//
//  DraftStatement.swift
//  EnactCLI
//
//  Created by JSilver on 11/10/26.
//

import Foundation

// A statement of a draft's main body, with the comments written above it,
// or comments alone where nothing could be written for what was done.
struct DraftStatement: Equatable {
    // MARK: - Property
    let comments: [String]
    let name: String?
    let value: DraftNode?
    
    // MARK: - Initializer
    init(_ value: DraftNode, named name: String? = nil, comments: [String] = []) {
        self.comments = comments
        self.name = name
        self.value = value
    }
    
    init(comment: String) {
        self.comments = [comment]
        self.name = nil
        self.value = nil
    }
    
    // MARK: - Public
    // The lines it is written as, at an indent.
    func lines(indent: String) -> [String] {
        let comments = comments.map { comment in "\(indent)# \(comment)" }
        
        guard let value else { return comments }
        
        guard let name else { return comments + ["\(indent)- value: \(value.flow)"] }
        
        return comments + ["\(indent)- let: \(name)", "\(indent)  value: \(value.flow)"]
    }
    
    // MARK: - Private
}

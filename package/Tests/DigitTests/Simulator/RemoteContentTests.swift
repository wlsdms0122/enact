//
//  RemoteContentTests.swift
//  DigitTests
//
//  Created by JSilver on 11/11/26.
//

import FBSimulatorAX
import Testing
@testable import Digit

@Suite("What a press at a point found in another process is told apart from the walked tree")
struct RemoteContentTests {
    // MARK: - Property
    private static let springBoard: Int64 = 50
    private static let webContent: Int64 = 70
    
    // MARK: - Initializer
    // MARK: - Test
    @Test("an application holds remote content where an element at any depth under it is remote")
    func remoteContentAtAnyDepthIsHeld() {
        // Given
        let sut = element(children: [element(children: [element(remote: true, pid: Self.webContent)])])
        
        // When
        let held = sut.holdsRemoteContent
        
        // Then
        #expect(held)
    }
    
    @Test("an application whose elements were all walked holds no remote content")
    func walkedTreeHoldsNoRemoteContent() {
        // Given
        let sut = element(children: [element(remote: false, pid: Self.springBoard)])
        
        // When
        let held = sut.holdsRemoteContent
        
        // Then
        #expect(!held)
    }
    
    @Test("removing a process's remote content keeps another's and the walked elements of that process")
    func removingKeepsOthers() {
        // Given
        let sut = element(children: [
            element(remote: true, pid: Self.springBoard),
            element(remote: false, pid: Self.springBoard),
            element(children: [element(remote: true, pid: Self.springBoard), element(remote: true, pid: Self.webContent)])
        ])
        
        // When
        let kept = sut.removingRemoteContent(of: Self.springBoard)
        
        // Then
        #expect(kept.children?.count == 2)
        #expect(kept.children?[0].isRemote == .some(false))
        #expect(kept.children?[1].children?.map(\.pid) == [.some(Self.webContent)])
    }
    
    @Test("removing the remote content of no process keeps all of it")
    func removingNoProcessKeepsAll() {
        // Given
        let sut = element(children: [element(remote: true, pid: Self.webContent)])
        
        // When
        let kept = sut.removingRemoteContent(of: nil)
        
        // Then
        #expect(kept.holdsRemoteContent)
    }
    
    // MARK: - Private
    private func element(
        remote: Bool? = nil,
        pid: Int64? = nil,
        children: [AccessibilityDocumentElement] = []
    ) -> AccessibilityDocumentElement {
        var element = AccessibilityDocumentElement(children: children)
        element.isRemote = .some(remote)
        element.pid = .some(pid)
        
        return element
    }
}

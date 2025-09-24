//
//  Component.swift
//  SwiftUITank
//
//  Created by Sergey Kozlov on 22.09.2025.
//

import SwiftUI
import Combine

open class Component: ObservableObject, Equatable {
    
    private(set) weak var owner: SceneNode?
    private var cancelables: Set<AnyCancellable> = []
    
    public var transform: Transform? {
        owner?.transform
    }
    
    public init(owner: SceneNode? = nil) {
        self.owner = owner
        passthroughTransformChanges()
    }
    
    
    internal func assignOwner(_ node: SceneNode?) {
        owner = node
        passthroughTransformChanges()
    }
    
    public static func == (lhs: Component, rhs: Component) -> Bool {
        return lhs === rhs
    }
    
    private func passthroughTransformChanges() {
        guard let owner else {
            cancelables.removeAll()
            return
        }
        owner.transform.$matrix.sink() { [unowned self] value in
            objectWillChange.send()
        }.store(in: &cancelables)
    }
}

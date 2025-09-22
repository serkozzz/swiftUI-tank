//
//  Component.swift
//  SwiftUITank
//
//  Created by Sergey Kozlov on 22.09.2025.
//

import Foundation

class Component: Equatable {
    
    private(set) weak var owner: SceneNode?
    
    func getTransform() -> Matrix? {
        owner?.transform
    }
    
    func setTransfrom(_ transform: Matrix) {
        owner?.transform = transform
    }
    
    internal func assignOwner(_ node: SceneNode?) {
        owner = node
    }
    
    static func == (lhs: Component, rhs: Component) -> Bool {
        return lhs === rhs
    }
}

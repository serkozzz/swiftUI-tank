//
//  Component.swift
//  SwiftUITank
//
//  Created by Sergey Kozlov on 22.09.2025.
//

import SwiftUI
import Combine

open class TEComponent2D: ObservableObject, Equatable {
    
    private(set) weak var owner: TESceneNode2D?
    private var cancelables: Set<AnyCancellable> = []
    
    public var transform: TETransform2D? {
        owner?.transform
    }
    
    public init(owner: TESceneNode2D? = nil) {
        self.owner = owner
        subscribeToTransform()
    }
    
    open func update() {
        
    }
    
    internal func assignOwner(_ node: TESceneNode2D?) {
        owner = node
        subscribeToTransform()
    }
    
    public static func == (lhs: TEComponent2D, rhs: TEComponent2D) -> Bool {
        return lhs === rhs
    }
    
    private func subscribeToTransform() {
        guard let owner else {
            cancelables.removeAll()
            return
        }
        owner.$transform.sink() { [unowned self] value in
            objectWillChange.send()
        }.store(in: &cancelables)
    }
}

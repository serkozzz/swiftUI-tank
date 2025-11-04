//
//  Component.swift
//  SwiftUITank
//
//  Created by Sergey Kozlov on 22.09.2025.
//

import SwiftUI
import Combine
import SafeKVC

@objcMembers
@MainActor
open class TEComponent2D: NSObject, ObservableObject {
    
    private(set) var id = UUID()
    public private(set) weak var owner: TESceneNode2D?
    
    var isStarted: Bool = false
    private var cancelables: Set<AnyCancellable> = []
    
    public var transform: TETransform2D? {
        owner?.transform
    }
    
    public var worldTransform: TETransform2D? {
        owner?.worldTransform
    }
    
    public override required init() {
        
    }
    
    
    /**  Start вызывается ТОЛЬКО ОДИН РАЗ, когда экземпляр впервые попадает в играющую сцену.
     
     Это может произойти в 3-х случаях:
     1. attach к живому узлу
     2. присоединение поддерева с этим узлом к живому дереву (если отсоединили узел и присоединили снова - повторного вызова не будет)
     3. при старте двжика вызывается start() для всех компонентов сцены, с которой движок стартует.
     
     Reattach запрещён после того, как компонент уже был присоединён и/или стартовал. (будет assert/precondition )
    */
    open func start() {
       
    }
    
    final internal func emitStartIfNeeded() {
        if (isStarted) { return }
        isStarted = true
        start()
    }
    
    open func update(timeFromLastUpdate: TimeInterval) {
    }
    
    
    open func collision(collider: TECollider2D) {
        
    }
    
    internal func assignOwner(_ node: TESceneNode2D?) {
        owner = node
        
    }
    
    nonisolated public static func == (lhs: TEComponent2D, rhs: TEComponent2D) -> Bool {
        return lhs === rhs
    }
}


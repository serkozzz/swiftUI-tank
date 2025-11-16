// The Swift Programming Language


import SwiftUI
import Combine
import simd

@MainActor
public class TETankEngine2D {
    public static let shared = TETankEngine2D()
    public private(set) var scene: TEScene2D!
    
    private var timerCancellable: Set<AnyCancellable> = []
    private var lastTickTime: Date?
    private var isPlaying: Bool = false
    private let collisionSystem = TECollisionSystem2D()
    
    private init() {
        collisionSystem.delegate = self
        TEComponentsRegister2D.shared.registerCoreComponents()
        TEViewsRegister2D.shared.registerCoreViews()
    }
    

    public func reset(withScene: TEScene2D, _ autoRegistrator: TEAutoRegistratorProtocol) {
        
        TEComponentsRegister2D.shared.setAutoRegistrator(autoRegistrator)
        TEViewsRegister2D.shared.setAutoRegistrator(autoRegistrator)
        
        isPlaying = false
        self.collisionSystem.reset()
        self.scene = withScene
        self.scene.delegate = self
        self.scene.rootNode.foreachInSubtree() {
            $0.components.forEach() {comp in comp.isAwaked = false; comp.isStarted = false }
        }
    }
    
    public func start(_ autoRegistrator: TEAutoRegistratorProtocol) {
        TEComponentsRegister2D.shared.setAutoRegistrator(autoRegistrator)
        TEViewsRegister2D.shared.setAutoRegistrator(autoRegistrator)
        
        isPlaying = true
        
        foreachComponentInSubtree(parentNode: scene.rootNode) { component in
            component.emitAwakeIfNeeded()
        }
        foreachComponentInSubtree(parentNode: scene.rootNode) { component in
            component.emitStartIfNeeded()
            registerInCollisionSystemIfNeeded(component)
        }
        
        timerCancellable.removeAll()
        
        Timer.publish(every: 0.04, on: .main, in: .common)
            .autoconnect()
            .sink { [unowned self] _ in
                tick()
            }
            .store(in: &timerCancellable)
    }
    

    public func pause() {
        isPlaying = false
        timerCancellable.removeAll()
        lastTickTime = nil
    }
}

extension TETankEngine2D {
    private func tick() {
        let now = Date.now
        guard let lastTickTime else {
            self.lastTickTime = now
            return
        }
        let timeFromLastTick = now.timeIntervalSince(lastTickTime) // секунды
        self.lastTickTime = now
        
        collisionSystem.collisionSystemPass()
        
        foreachComponentInSubtree(parentNode: scene.rootNode) { component in
            component.update(timeFromLastUpdate: timeFromLastTick)
        }
    }
    
    private func foreachComponentInSubtree(parentNode: TESceneNode2D, closure: (TEComponent2D) -> Void) {
   
        for component in parentNode.components {
            closure(component)
        }
        for child in parentNode.children {
            foreachComponentInSubtree(parentNode: child, closure: closure)
        }

    }
}

extension TETankEngine2D : TEScene2DDelegate {
    
    func teScene2D(_ scene: TEScene2D, didAddNode node: TESceneNode2D) {
        guard isPlaying else { return }
        
        foreachComponentInSubtree(parentNode: node) { component in
            component.emitAwakeIfNeeded()
        }
        
        foreachComponentInSubtree(parentNode: node) { component in
            component.emitStartIfNeeded()
            registerInCollisionSystemIfNeeded(component)
        }
    }
    
    func teScene2D(_ scene: TEScene2D, willRemoveNode node: TESceneNode2D) {
        foreachComponentInSubtree(parentNode: node) { component in
            unregisterInCollisionSystemIfNeeded(component)
        }
    }
    
    func teScene2D(_ scene: TEScene2D, didAttachComponent component: TEComponent2D, to node: TESceneNode2D) {
        guard isPlaying else { return }
        component.emitAwakeIfNeeded()
        component.emitStartIfNeeded()
        registerInCollisionSystemIfNeeded(component)
    }
    
    func teScene2D(_ scene: TEScene2D, willDetachComponent component: TEComponent2D, from node: TESceneNode2D) {
        unregisterInCollisionSystemIfNeeded(component)
    }
}


extension TETankEngine2D: TECollisionSystem2DDelegate {
    func teCollisionSystem2D(_ collisionSystem: TECollisionSystem2D, didDetectCollisionBetween collider1: TECollider2D, and collider2: TECollider2D) {
       
        for component in collider1.owner!.components {
            component.collision(collider: collider2)
        }
        
        for component in collider2.owner!.components {
            component.collision(collider: collider1)
        }
    }
    
    private func registerInCollisionSystemIfNeeded(_ component: TEComponent2D) {
        guard let collider = component as? TECollider2D else  { return }
        collisionSystem.register(collider: collider)
    }
    
    private func unregisterInCollisionSystemIfNeeded(_ component: TEComponent2D) {
        guard let collider = component as? TECollider2D else  { return }
        collisionSystem.unregister(collider: collider)
    }
}



extension TETankEngine2D {
    /// Predictively evaluates whether moving the given node to a target WORLD transform
    /// would keep all of its colliders inside the scene bounds and which other colliders
    /// it would intersect at that target.
    public func predictiveMove(sceneNode: TESceneNode2D, newWorldTransform: TETransform2D) -> TEPredictiveMoveResult {
        return collisionSystem.predictiveMove(sceneNode: sceneNode,
                                              newWorldTransform: newWorldTransform,
                                              sceneBounds: TEAABB(rect: scene.sceneBounds))
    }
}


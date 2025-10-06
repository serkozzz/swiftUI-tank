// The Swift Programming Language
// https://docs.swift.org/swift-book

import SwiftUI
import Combine

@MainActor
public class TETankEngine2D {
    public static let shared = TETankEngine2D()
    public private(set) var scene: TEScene2D!
    
    private var cancellables: Set<AnyCancellable> = []
    private var lastTickTime: Date?
    private var isPlaying: Bool = false
    private let collisionSystem = TECollisionSystem2D()
    
    private init() {
        collisionSystem.delegate = self
    }
    
    public func setScene(scene: TEScene2D) {
        self.scene = scene
        self.scene.delegate = self
    }
    
    public func start() {
        isPlaying = true
        
        foreachComponentInSubtree(parentNode: scene.rootNode) { component in
            component.emitStartIfNeeded()
        }
        
        cancellables.removeAll()
        
        Timer.publish(every: 0.04, on: .main, in: .common)
            .autoconnect()
            .sink { [unowned self] _ in
                tick()
            }
            .store(in: &cancellables)
    }
    

    public func pause() {
        isPlaying = false
        cancellables.removeAll()
        lastTickTime = nil
    }
}

extension TETankEngine2D {
    func tick() {
        let now = Date.now
        guard let lastTickTime else {
            self.lastTickTime = now
            return
        }
        let timeFromLastTick = now.timeIntervalSince(lastTickTime) // секунды
        self.lastTickTime = now
        
        foreachComponentInSubtree(parentNode: scene.rootNode) { component in
            component.update(timeFromLastUpdate: timeFromLastTick)
            registerInCollisionSystemIfNeeded(component)
        }
        
        collisionSystem.checkCollisions()
    }
    
    func foreachComponentInSubtree(parentNode: TESceneNode2D, closure: (TEComponent2D) -> Void) {
   
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

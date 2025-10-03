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
    
    private init() {
    }
    
    public func start(scene: TEScene2D) {
        isPlaying = true
        self.scene = scene
        
        foreach(parentNode: scene.rootNode) { component in
            component.start()
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

    }
    
    public func stop() {
        isPlaying = false
        cancellables.removeAll()
        scene = nil
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
        
        foreach(parentNode: scene.rootNode) { component in
            component.update(timeFromLastUpdate: timeFromLastTick)
        }
    }
    
    func foreach(parentNode: TESceneNode2D, closure: (TEComponent2D) -> Void) {
   
        for component in parentNode.components {
            closure(component)
        }
        for child in parentNode.children {
            foreach(parentNode: child, closure: closure)
        }

    }
}

extension TETankEngine2D {
    func registerAttachment(component: TEComponent2D, to sceneNode: TESceneNode2D) {
        if (!isPlaying) { return }
        component.start()
    }
    
    func registerDetachment(component: TEComponent2D, from sceneNode: TESceneNode2D) {
        
    }
}

extension TETankEngine2D : TEScene2DDelegate {
    func teScene2D(_ scene: TEScene2D, didAddNode node: TESceneNode2D) {
        
    }
    
    func teScene2D(_ scene: TEScene2D, didRemoveNode node: TESceneNode2D) {
        
    }
    
    func teScene2D(_ scene: TEScene2D, didAttachComponent component: TEComponent2D, to node: TESceneNode2D) {
        
    }
    
    func teScene2D(_ scene: TEScene2D, didDetachComponent component: TEComponent2D, from node: TESceneNode2D) {
        
    }
    
    
}

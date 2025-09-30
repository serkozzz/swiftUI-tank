// The Swift Programming Language
// https://docs.swift.org/swift-book

import SwiftUI
import Combine

@MainActor
public class TETankEngine2D {
    public static private(set) var shared = TETankEngine2D()
    public private(set) var scene: TEScene2D!
    
    private var cancellables: Set<AnyCancellable> = []
    private var lastTickTime: Date?
    private init() {
    }
    
    public func start(scene: TEScene2D) {
        self.scene = scene
        cancellables.removeAll()
        
        Timer.publish(every: 0.04, on: .main, in: .common)
            .autoconnect()
            .sink { [unowned self] _ in
                tick()
            }
            .store(in: &cancellables)
    }
    
    public func stop() {
        cancellables.removeAll()
        scene = nil
    }
}

extension TETankEngine2D {
    func tick() {
        guard let lastTickTime else {
            lastTickTime = Date.now
            return
        }
        let timeFromLastTick = Date.now.timeIntervalSince(lastTickTime)
        
        for node in scene.nodes {
            for component in node.components {
                component.update(timeFromLastUpdate: timeFromLastTick)
            }
        }
    }
}

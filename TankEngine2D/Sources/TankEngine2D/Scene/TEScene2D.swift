//
//  Scene.swift
//  SwiftUITank
//
//  Created by Sergey Kozlov on 20.09.2025.
//

import SwiftUI
import Combine

public class TEScene2D: ObservableObject {
    
    private var nodeCancellables: Set<AnyCancellable> = []
    private var cancellables: Set<AnyCancellable> = []
    
    
    public init(nodes: [TESceneNode2D], camera: TECamera2D) {
        self.nodes = nodes
        self.camera = camera
        
        let cameraNode = TESceneNode2D(position: SIMD2<Float>(0, 0), component: camera)
        self.nodes.append(cameraNode)
        
        
        $nodes.sink { [unowned self] nodes in
            setupNodesSubscription(nodes)
        }.store(in: &cancellables)
//        setupNodesSubscription(nodes)
    }
    
    private func setupNodesSubscription(_ nodes: [TESceneNode2D]) {
        nodeCancellables.removeAll()
        for node in nodes {
            node.objectWillChange.sink { [unowned self] _ in
                self.objectWillChange.send()
            }.store(in: &nodeCancellables)
        }
    }
    
    @Published public var camera: TECamera2D
    @Published public var nodes: [TESceneNode2D]
}

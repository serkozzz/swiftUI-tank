//
//  Scene.swift
//  SwiftUITank
//
//  Created by Sergey Kozlov on 20.09.2025.
//

import SwiftUI

class Scene2D: ObservableObject {
    
    init(nodes: [SceneNode], camera: Camera) {
        self.nodes = nodes
        self.camera = camera
        
        let cameraNode = SceneNode(position: SIMD2<Float>(0, 0), component: camera)
        self.nodes.append(cameraNode)
    }
    
    var camera: Camera
    var nodes: [SceneNode]
}


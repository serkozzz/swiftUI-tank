//
//  Scene.swift
//  SwiftUITank
//
//  Created by Sergey Kozlov on 20.09.2025.
//

import SwiftUI

public class TEScene2D: ObservableObject {
    
    public init(nodes: [TESceneNode2D], camera: TECamera2D) {
        self.nodes = nodes
        self.camera = camera
        
        let cameraNode = TESceneNode2D(position: SIMD2<Float>(0, 0), component: camera)
        self.nodes.append(cameraNode)
    }
    
    public var camera: TECamera2D
    public var nodes: [TESceneNode2D]
}


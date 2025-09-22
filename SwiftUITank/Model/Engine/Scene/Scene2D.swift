//
//  Scene.swift
//  SwiftUITank
//
//  Created by Sergey Kozlov on 20.09.2025.
//

import SwiftUI

class Scene2D: ObservableObject {
    
    init(nodes: [SceneNode]) {
        self.nodes = nodes
    }
    
    var camera = Camera()
    var player = PlayerTank()
    var nodes: [SceneNode]
}


extension Scene2D {
    static var `default` = {
        var nodes: [SceneNode] = []
        
        var artilary1 = GeometryObject(.artillery, boundingBox: CGSize(width: 50, height: 50))
        var artilary2 = GeometryObject(.artillery, boundingBox: CGSize(width: 100, height: 50))
        
        var wall1 = GeometryObject(.static, boundingBox: CGSize(width: 100, height: 50))
        var wall2 = GeometryObject(.static, boundingBox: CGSize(width: 50, height: 200))
        
        nodes = [
            SceneNode(position: SIMD2<Float>(300, 800), geometryObject: artilary1),
            SceneNode(position: SIMD2<Float>(100, 400), geometryObject: artilary2),
            SceneNode(position: SIMD2<Float>(200, 200), geometryObject: wall1),
            SceneNode(position: SIMD2<Float>(400, 1000), geometryObject: wall2)
        ]
        
        return Scene2D(nodes: nodes)
    }()
}

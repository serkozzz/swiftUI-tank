//
//  Scene2D+default.swift
//  SwiftUITank
//
//  Created by Sergey Kozlov on 24.09.2025.
//

import Foundation

extension Scene2D {
    static var `default` = {
        var nodes: [SceneNode] = []
        
        let camera = Camera()
        
        var artilary1 = GeometryObject(.artillery, boundingBox: CGSize(width: 50, height: 50))
        var artilary2 = GeometryObject(.artillery, boundingBox: CGSize(width: 100, height: 50))
        
        var wall1 = GeometryObject(.static, boundingBox: CGSize(width: 100, height: 50))
        var wall2 = GeometryObject(.static, boundingBox: CGSize(width: 50, height: 200))
        
        nodes = [
            SceneNode(position: SIMD2<Float>(100, 100), component: PlayerTank()),

            SceneNode(position: SIMD2<Float>(300, 800), component: artilary1),
            SceneNode(position: SIMD2<Float>(100, 400), component: artilary2),
            SceneNode(position: SIMD2<Float>(200, 200), component: wall1),
            SceneNode(position: SIMD2<Float>(400, 1000), component: wall2)
        ]
        
        return Scene2D(nodes: nodes, camera: camera)
    }()
}

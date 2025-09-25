//
//  Scene2D+default.swift
//  SwiftUITank
//
//  Created by Sergey Kozlov on 24.09.2025.
//

import Foundation
import TankEngine2D

extension TEScene2D {
    static var `default` = {
        var nodes: [TESceneNode2D] = []
        
        let camera = TECamera2D()
        
        var artilary1 = TEGeometryObject2D(.artillery, boundingBox: CGSize(width: 50, height: 50))
        var artilary2 = TEGeometryObject2D(.artillery, boundingBox: CGSize(width: 100, height: 50))
        
        var wall1 = TEGeometryObject2D(.static, boundingBox: CGSize(width: 100, height: 50))
        var wall2 = TEGeometryObject2D(.static, boundingBox: CGSize(width: 50, height: 200))
        
        nodes = [
            TESceneNode2D(position: SIMD2<Float>(100, 100), component: PlayerTank()),

            TESceneNode2D(position: SIMD2<Float>(300, 800), component: artilary1),
            TESceneNode2D(position: SIMD2<Float>(100, 400), component: artilary2),
            TESceneNode2D(position: SIMD2<Float>(200, 200), component: wall1),
            TESceneNode2D(position: SIMD2<Float>(400, 1000), component: wall2)
        ]
        
        return TEScene2D(nodes: nodes, camera: camera)
    }()
}

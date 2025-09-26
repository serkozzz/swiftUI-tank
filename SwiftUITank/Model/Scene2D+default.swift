//
//  Scene2D+default.swift
//  SwiftUITank
//
//  Created by Sergey Kozlov on 24.09.2025.
//

import Foundation
import TankEngine2D
import SwiftUI

extension TEScene2D {
    
    func addSceneObject<T: BaseSceneObject>(_ model: T,
                                            position: SIMD2<Float>,
                                            boundingBox: CGSize,
                                            view: AnyView) {
        let sceneNode = TESceneNode2D(position: position, component: model)
        let go = TEGeometryObject2D(view, boundingBox: boundingBox)
        sceneNode.attachComponent(go)
        nodes.append(sceneNode)
    }
    
    static var `default` = {
        var nodes: [TESceneNode2D] = [
            TESceneNode2D(position: SIMD2<Float>(100, 100), component: PlayerTank()),
        ]
        
        let camera = TECamera2D()
        let scene2D = TEScene2D(nodes: nodes, camera: camera)
        
        var cannon1 = Cannon()
        scene2D.addSceneObject(cannon1,
                               position: SIMD2<Float>(300, 800),
                               boundingBox: CGSize(width: 50, height: 50),
                               view: AnyView(CannonView(cannon1)))
        
        var cannon2 = Cannon()
        scene2D.addSceneObject(cannon2,
                               position: SIMD2<Float>(100, 400),
                               boundingBox: CGSize(width: 100, height: 50),
                               view: AnyView(CannonView(cannon1)))
        

        return scene2D

    }()
}

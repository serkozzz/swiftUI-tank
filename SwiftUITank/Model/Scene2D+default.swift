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
                                            to parent: TESceneNode2D,
                                            position: SIMD2<Float>,
                                            boundingBox: CGSize,
                                            view: AnyView) {
        let sceneNode = TESceneNode2D(position: position, component: model)
        let go = TEGeometryObject2D(view, boundingBox: boundingBox)
        sceneNode.attachComponent(go)
        parent.addChild(sceneNode)
    }
    
    func addPlayerTank(tankModel: PlayerTank)  {
        addSceneObject(tankModel,
                       to: rootNode,
                       position: SIMD2<Float>(100, 100),
                       boundingBox: CGSize(width: 50, height: 50),
                       view: AnyView(TankView(tank: tankModel)))
        
    }
    
    @MainActor static var `default` = {
        var nodes: [TESceneNode2D] = []
        
        let camera = TECamera2D()
        let scene2D = TEScene2D(camera: camera)
        
        var cannon1 = Cannon()
        scene2D.addSceneObject(cannon1,
                               to: scene2D.rootNode,
                               position: SIMD2<Float>(300, 800),
                               boundingBox: CGSize(width: 50, height: 50),
                               view: AnyView(CannonView(cannon1)))
        
        var cannon2 = Cannon()
        scene2D.addSceneObject(cannon2,
                               to: scene2D.rootNode,
                               position: SIMD2<Float>(100, 400),
                               boundingBox: CGSize(width: 100, height: 50),
                               view: AnyView(CannonView(cannon1)))
        
        var building1 = Building(floorsNumber: 5)
        scene2D.addSceneObject(building1,
                               to: scene2D.rootNode,
                               position: SIMD2<Float>(300, 300),
                               boundingBox: CGSize(width: 100, height: 50),
                               view: AnyView(BuildingView(building1)))
        
        var building2 = Building(floorsNumber: 10)
        scene2D.addSceneObject(building2,
                               to: scene2D.rootNode,
                               position: SIMD2<Float>(200, 500),
                               boundingBox: CGSize(width: 100, height: 100),
                               view: AnyView(BuildingView(building2)))
        
        

        return scene2D

    }()
    
    
    @MainActor static var `default2` = {
        var nodes: [TESceneNode2D] = []
        
        let camera = TECamera2D()
        let scene2D = TEScene2D(camera: camera)
        
        var cannon1 = Cannon()
        scene2D.addSceneObject(cannon1,
                               to: scene2D.rootNode,
                               position: SIMD2<Float>(400, 100),
                               boundingBox: CGSize(width: 30, height: 30),
                               view: AnyView(CannonView(cannon1)))
        
        return scene2D

    }()
}

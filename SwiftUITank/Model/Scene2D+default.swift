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
    
    @discardableResult
    func addSceneObject<T: BaseSceneObject>(_ model: T,
                                            to parent: TESceneNode2D,
                                            position: SIMD2<Float>,
                                            boundingBox: CGSize,
                                            view: AnyView,
                                            debugName: String? = nil) -> TESceneNode2D {
        let sceneNode = TESceneNode2D(position: position, component: model, debugName: debugName)
        let go = TEGeometryObject2D(view, boundingBox: boundingBox)
        let collider = TECollider2D()
        sceneNode.attachComponent(go)
        sceneNode.attachComponent(collider)
        parent.addChild(sceneNode)
        return sceneNode
    }
    
    @discardableResult
    func addPlayerTank(tankModel: PlayerTank) -> TESceneNode2D  {
        addSceneObject(tankModel,
                       to: rootNode,
                       position: SIMD2<Float>(0, 0),
                       boundingBox: CGSize(width: 50, height: 50),
                       view: AnyView(TankView(tank: tankModel)),
                       debugName: "playerTank")
        
    }
    
    func addPlayerController(_ playerController: PlayerController)  {
        let node = TESceneNode2D(position: .zero, component: playerController, debugName: "PlayerController")
        rootNode.addChild(node)
    }
    
    @MainActor static var `default`: TEScene2D {
            
        let camera = TECamera2D()
        let sceneBounds = CGRect(origin: CGPoint(x: -300, y: -100), size: CGSize(width: 600, height: 1000))
        let scene2D = TEScene2D(sceneBounds: sceneBounds,
                                camera: camera)
        
        let cannon1 = Cannon()
        scene2D.addSceneObject(cannon1,
                               to: scene2D.rootNode,
                               position: SIMD2<Float>(300, 800),
                               boundingBox: CGSize(width: 50, height: 50),
                               view: AnyView(CannonView(cannon1)),
                               debugName: "cannon1")
        
        let cannon2 = Cannon()
        scene2D.addSceneObject(cannon2,
                               to: scene2D.rootNode,
                               position: SIMD2<Float>(100, 400),
                               boundingBox: CGSize(width: 100, height: 50),
                               view: AnyView(CannonView(cannon1)),
                               debugName: "cannon2")
        
        let building1 = Building(floorsNumber: 5)
        scene2D.addSceneObject(building1,
                               to: scene2D.rootNode,
                               position: SIMD2<Float>(300, 300),
                               boundingBox: CGSize(width: 100, height: 50),
                               view: AnyView(BuildingView(building1)),
                               debugName: "building1")
        
        let building2 = Building(floorsNumber: 10)
        scene2D.addSceneObject(building2,
                               to: scene2D.rootNode,
                               position: SIMD2<Float>(200, 500),
                               boundingBox: CGSize(width: 100, height: 100),
                               view: AnyView(BuildingView(building2)),
                               debugName: "building2")
        
        

        return scene2D

    }
    
    
    @MainActor static var `default2`: TEScene2D {
        
        let camera = TECamera2D()
        let sceneBounds = CGRect(origin: CGPoint(x: -200, y: -200), size: CGSize(width: 400, height: 1000))
        let scene2D = TEScene2D(sceneBounds: sceneBounds,
                                camera: camera)
        let cannon1 = Cannon()
        scene2D.addSceneObject(cannon1,
                               to: scene2D.rootNode,
                               position: SIMD2<Float>(400, 100),
                               boundingBox: CGSize(width: 30, height: 30),
                               view: AnyView(CannonView(cannon1)),
                               debugName: "cannon1")
        

        
        return scene2D

    }
    
    @MainActor static var empty: TEScene2D {
        
        let camera = TECamera2D()
        let sceneBounds = CGRect(origin: CGPoint(x: -200, y: -200), size: CGSize(width: 400, height: 1000))
        let scene2D = TEScene2D(sceneBounds: sceneBounds,
                                camera: camera)
        
        return scene2D

    }
}

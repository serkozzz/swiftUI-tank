//
//  Scene2D+default.swift
//  SwiftUITank
//
//  Created by Sergey Kozlov on 24.09.2025.
//

import Foundation
import SwiftUI

extension TEScene2D {
    
    static var savedSceneData: Data?
    
    @discardableResult
    func addSceneObject<C: BaseSceneObject>(to parent: TESceneNode2D,
                                position: SIMD2<Float>,
                                viewType: any TEView2D.Type,
                                viewModelType: C.Type,
                                tag: String? = nil) -> (TESceneNode2D, C)  {

        let sceneNode = TESceneNode2D(position: position, viewType: viewType, viewModelType: viewModelType, tag: tag)
        let viewModel = sceneNode.getComponent(viewModelType)!
        sceneNode.attachComponent(TECollider2D.self)
        parent.addChild(sceneNode)
        return (sceneNode, viewModel)
    }
    
    @discardableResult
    func addPlayerTank() -> (TESceneNode2D, PlayerTank)  {
        addSceneObject(to: rootNode,
                       position: SIMD2<Float>(0, 0),
                       viewType: TankView.self,
                       viewModelType: PlayerTank.self,
                       tag: "PlayerTank")
    }
    
    func addPlayerController(with playerTank: PlayerTank) -> PlayerController  {
        let node = TESceneNode2D(position: .zero, tag: "PlayerController")
        let playerController = node.attachComponent(PlayerController.self) as! PlayerController
        rootNode.addChild(node)
        return playerController
    }
    
    @MainActor static var `default`: TEScene2D {
            
        let sceneBounds = CGRect(origin: CGPoint(x: -300, y: -100), size: CGSize(width: 600, height: 1000))
        let scene2D = TEScene2D(sceneBounds: sceneBounds)
        
        
        let (_, cannon1) = scene2D.addSceneObject(to: scene2D.rootNode,
                               position: SIMD2<Float>(300, 800),
                               viewType: CannonView.self,
                                                  viewModelType: Cannon.self,
                               tag: "cannon1")
        cannon1.boundingBox = CGSize(width: 50, height: 50)
        


        let (_, cannon2) = scene2D.addSceneObject(to: scene2D.rootNode,
                               position: SIMD2<Float>(100, 400),
                               viewType: CannonView.self,
                               viewModelType: Cannon.self,
                               tag: "cannon2")
        cannon2.boundingBox = CGSize(width: 100, height: 50)
        
        let (_, building1) = scene2D.addSceneObject(to: scene2D.rootNode,
                               position: SIMD2<Float>(300, 300),
                               viewType: BuildingView.self,
                               viewModelType: Building.self,
                               tag: "building1")
        building1.floorsNumber = 5
        building1.boundingBox = CGSize(width: 100, height: 50)
        


        let (_, building2) = scene2D.addSceneObject(to: scene2D.rootNode,
                               position: SIMD2<Float>(200, 500),
                               viewType: BuildingView.self,
                               viewModelType: Building.self,
                               tag: "building2")
        building2.floorsNumber = 10
        building2.boundingBox = CGSize(width: 100, height: 100)

        return scene2D

    }
    
    
    @MainActor static var `default2`: TEScene2D {
        
        let sceneBounds = CGRect(origin: CGPoint(x: -200, y: -200), size: CGSize(width: 400, height: 1000))
        let scene2D = TEScene2D(sceneBounds: sceneBounds)
        
        
        let (_, cannon1) = scene2D.addSceneObject(to: scene2D.rootNode,
                                                  position: SIMD2<Float>(400, 100),
                                                  viewType: CannonView.self,
                                                  viewModelType: Cannon.self,
                                                  tag: "cannon1")
        cannon1.boundingBox = CGSize(width: 30, height: 30)
        
        return scene2D
        
    }
    
    @MainActor static var empty: TEScene2D {
        
        let sceneBounds = CGRect(origin: CGPoint(x: -200, y: -200), size: CGSize(width: 400, height: 1000))
        let scene2D = TEScene2D(sceneBounds: sceneBounds)
        
        return scene2D

    }
}

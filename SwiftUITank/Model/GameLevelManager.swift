//
//  GameManager.swift
//  SwiftUITank
//
//  Created by Sergey Kozlov on 01.10.2025.
//

import SwiftUI
import TankEngine2D

@MainActor
class GameLevelManager: ObservableObject {
    
    let levelContext: GameLevelContext
    
    private let scene: TEScene2D
    private let damageSystem: DamageSystem
    
    init(scene: TEScene2D) {
        let playerTank = PlayerTank()
        let playerNode = scene.addPlayerTank(tankModel: playerTank)
        
        //attach camera to player

        let cameraNode = scene.camera.owner!
        playerNode.addChild(cameraNode)
        
 //       addTestSubtreeToPlayer(scene: scene, playerNode: playerNode)
        
//        let building = Building()
//        let _ = scene.addSceneObject(building,
//                                     to: scene.rootNode,
//                                     position: SIMD2<Float>(30, 0),
//                                             boundingBox: CGSize(width: 30, height: 30),
//                                             view: AnyView(BuildingView(building)),
//                                             debugName: "building")
//        
//        let building2 = Building()
//        let _ = scene.addSceneObject(building2,
//                                     to: scene.rootNode,
//                                     position: SIMD2<Float>(150, 0),
//                                             boundingBox: CGSize(width: 30, height: 30),
//                                             view: AnyView(BuildingView(building2)),
//                                             debugName: "building")

        self.scene = scene
        
        let playerController = PlayerController(playerTank, scene: scene)
        scene.addPlayerController(playerController)
        
        levelContext = GameLevelContext(scene: scene, playerTank: playerTank, playerController: playerController)
        damageSystem = DamageSystem(scene: scene)
        playerController.delegate = self
        
        
        TETankEngine2D.shared.reset(withScene: scene)
        TETankEngine2D.shared.start()
        self.scene.printGraph()
    }
    
    
    func spawnBullet(_ bullet: Bullet) {
        print("spawnBullet")
        scene.addSceneObject(bullet,
                             to: scene.rootNode,
                             position: bullet.startPosition,
                             boundingBox: bullet.size.cgSize,
                             view: AnyView(BulletView(bullet: bullet)))
        
        damageSystem.registerBullet(bullet)
    }
}

@MainActor
extension GameLevelManager: PlayerControllerDelegate {
    func playerController(_ playerController: PlayerController, initiatedShootingWith bullet: Bullet) {
        spawnBullet(bullet)
    }
    
}

@MainActor
private func addTestSubtreeToPlayer(scene: TEScene2D, playerNode: TESceneNode2D) {
        let grandparentRadar = Radar(color: .blue)
        let parentRadar = Radar(color: .black)
        let radar = Radar(color: .red)
        
        let emptyNode = TESceneNode2D(position: .zero)
        let emptyNodeParent = TESceneNode2D(position: .zero)
        let emptyNodeGrand = TESceneNode2D(position: .zero)
        playerNode.addChild(emptyNodeGrand)
        emptyNodeGrand.addChild(emptyNodeParent)
        emptyNodeParent.addChild(emptyNode)

        

        let grandparentRadarNode = scene.addSceneObject(grandparentRadar,
                                             to: emptyNode,
                                             position: .zero,
                                             boundingBox: CGSize(width: 30, height: 30),
                                             view: AnyView(RadarView(model: grandparentRadar)),
                                             debugName: "grandparentRadar")

        
        
        let parentRadarNode = scene.addSceneObject(parentRadar,
                                             to: grandparentRadarNode,
                                             position: .zero,
                                             boundingBox: CGSize(width: 30, height: 30),
                                             view: AnyView(RadarView(model: parentRadar)),
                                             debugName: "parentRadar")
        
        let _ = scene.addSceneObject(radar,
                                             to: parentRadarNode,
                                             position: .zero,
                                             boundingBox: CGSize(width: 30, height: 30),
                                             view: AnyView(RadarView(model: radar)),
                                             debugName: "radar")
    }



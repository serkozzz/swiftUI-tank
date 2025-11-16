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
        
        let (playerNode, playerTank) = scene.addPlayerTank()
        self.scene = scene
        let playerController = scene.addPlayerController(with: playerTank)
        
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


        
        levelContext = GameLevelContext(scene: scene, playerTank: playerTank, playerController: playerController)
        damageSystem = DamageSystem(scene: scene)
        playerController.delegate = self
        
        
        TETankEngine2D.shared.reset(withScene: scene, TEAutoRegistrator2D())
        TETankEngine2D.shared.start(TEAutoRegistrator2D())
        self.scene.printGraph()
    }
    
    init(sceneDataFromSaves: Data) {
        let scene = TESceneSaver2D().load(jsonData: sceneDataFromSaves)!
        
        let playerTank = scene.rootNode.getNodeBy(tag: "PlayerTank")!.getComponent(PlayerTank.self)!
        let playerController = scene.rootNode.getNodeBy(tag: "PlayerController")!.getComponent(PlayerController.self)!
        
        self.scene = scene
        levelContext = GameLevelContext(scene: scene, playerTank: playerTank, playerController: playerController)
        damageSystem = DamageSystem(scene: scene)
        playerController.delegate = self
        TETankEngine2D.shared.reset(withScene: scene, TEAutoRegistrator2D())
        
        
        let bullets = scene.rootNode.getNodesBy(tag: "bullet")
        for bullet in bullets {
            damageSystem.registerBullet(bullet.getComponent(Bullet.self)!)
        }
        TETankEngine2D.shared.start(TEAutoRegistrator2D())
        self.scene.printGraph()
    }
    
    
    func spawnBullet(_ bullet: Bullet) {
        print("spawnBullet")
        let (_, liveBullet) = scene.addSceneObject(to: scene.rootNode,
                             position: bullet.startPosition,
                             viewType: BulletView.self,
                             viewModelType: Bullet.self,
                             tag: "bullet")
        liveBullet.initFrom(other: bullet)
        
        damageSystem.registerBullet(liveBullet)
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
    
    let emptyNode = TESceneNode2D(position: .zero)
    let emptyNodeParent = TESceneNode2D(position: .zero)
    let emptyNodeGrand = TESceneNode2D(position: .zero)
    playerNode.addChild(emptyNodeGrand)
    emptyNodeGrand.addChild(emptyNodeParent)
    emptyNodeParent.addChild(emptyNode)
    
    
    let (grandparentRadarNode, grRadar) = scene.addSceneObject(to: scene.rootNode,
                                 position: .zero,
                                 viewType: RadarView.self,
                                 viewModelType: Radar.self,
                                 tag: "grandparentRadar")
    grRadar.color = .blue
    
    
    
    let (parentRadarNode, parRadar) = scene.addSceneObject(to: grandparentRadarNode,
                                               position: .zero,
                                               viewType: RadarView.self,
                                               viewModelType: Radar.self,
                                               tag: "parentRadar")
    parRadar.color = .black
    
    let (_, radar) = scene.addSceneObject(to: parentRadarNode,
                                 position: .zero,
                                 viewType: RadarView.self,
                                 viewModelType: Radar.self,
                                 tag: "radar")
    radar.color = .red
    
}



//
//  GameViewModel.swift
//  SimpleGame
//
//  Created by Sergey Kozlov on 08.11.2025.
//

import SwiftUI
import TankEngine2D
import Combine


class GameViewModel: ObservableObject {
    @Published private(set) var scene: TEScene2D
    
    private var sceneData: Data?
    init() {
        scene = createSceneAndPrepareEngine()
    }
    
    func reset(withScene newScene: TEScene2D) {
        TETankEngine2D.shared.reset(withScene: newScene)
        TETankEngine2D.shared.start()
        self.scene = newScene
    }
    
    func saveScene() {
        sceneData = TESceneSaver2D().save(scene)!
    }
    
    func loadScene() {
        guard let data = sceneData else { return }
        guard let newScene = TESceneSaver2D().load(jsonData: data) else { return }
        reset(withScene: newScene)
    }
    
    func tap() {
        let playerNode = scene.rootNode.children.first(where: { $0.tag == "player" })!
        //let player = playerNode.getComponent(PlayerLogic.self)
        //player?.tap()
    }
}


private func createSceneAndPrepareEngine() -> TEScene2D {
    
    //PluginLoader.shared.load()
    
    let sceneBounds = CGRect(origin: CGPoint(x: -300, y: -100), size: CGSize(width: 600, height: 1000))
    let scene2D = TEScene2D(sceneBounds: sceneBounds)
    
    let componentsDict = TEComponentsRegister2D.shared.components
    let playerLogic = componentsDict[componentsDict.keys.first!]!
    
    let  viewsDict = TEViewsRegister2D.shared.views
   // let circleViewType = viewsDict[viewsDict.keys.dropFirst().first!]!
    let circleViewType = viewsDict[viewsDict.keys.first!]!

    
    
    let rect = TESceneNode2D(position: SIMD2(0,200), viewType: circleViewType, viewModelType: playerLogic, tag: "player")

    scene2D.rootNode.addChild(rect)
    
    
    TETankEngine2D.shared.reset(withScene: scene2D)
    TETankEngine2D.shared.start()
    return scene2D
}

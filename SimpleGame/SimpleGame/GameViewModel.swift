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
        let player = playerNode.getComponent(PlayerLogic.self)
        player?.tap()
    }
}


private func createSceneAndPrepareEngine() -> TEScene2D {
    
    TEViewsRegister2D.shared.register(CircleView.self)
    TEViewsRegister2D.shared.register(RectView.self)
    TEComponentsRegister2D.shared.register(PlayerLogic.self)
    
    let sceneBounds = CGRect(origin: CGPoint(x: -300, y: -100), size: CGSize(width: 600, height: 1000))
    let scene2D = TEScene2D(sceneBounds: sceneBounds)
    
    let rect = TESceneNode2D(position: SIMD2(0,200), viewType: RectView.self, viewModelType: PlayerLogic.self, tag: "player")
    scene2D.rootNode.addChild(TESceneNode2D(position: SIMD2(0,0), viewType: CircleView.self))
    scene2D.rootNode.addChild(TESceneNode2D(position: SIMD2(200,200), viewType: CircleView.self))
    scene2D.rootNode.addChild(rect)
    
    
    TETankEngine2D.shared.reset(withScene: scene2D)
    return scene2D
}

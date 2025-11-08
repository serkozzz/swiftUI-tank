//
//  SimpleGameApp.swift
//  SimpleGame
//
//  Created by Sergey Kozlov on 07.11.2025.
//

import SwiftUI
import TankEngine2D

@main
struct SimpleGameApp: App {
    let scene2D = createSceneAndPrepareEngine()
    var body: some Scene {
        WindowGroup {
            ContentView(scene: scene2D)
        }
    }
}


func createSceneAndPrepareEngine() -> TEScene2D {
    
    TEViewsRegister2D.shared.register(CircleView.self)
    TEViewsRegister2D.shared.register(RectView.self)
    TEComponentsRegister2D.shared.register(PlayerLogic.self)
    
    let camera = TECamera2D()
    let sceneBounds = CGRect(origin: CGPoint(x: -300, y: -100), size: CGSize(width: 600, height: 1000))
    let scene2D = TEScene2D(sceneBounds: sceneBounds,
                            camera: camera)
    
    let player = PlayerLogic()
    let rect = TESceneNode2D(position: SIMD2(0,200), viewType: RectView.self, viewModel: player)
    rect.tag = "player"
    scene2D.rootNode.addChild(TESceneNode2D(position: SIMD2(0,0), viewType: CircleView.self, viewModel: nil))
    scene2D.rootNode.addChild(TESceneNode2D(position: SIMD2(200,200), viewType: CircleView.self, viewModel: nil))
    scene2D.rootNode.addChild(rect)
    
    
    TETankEngine2D.shared.reset(withScene: scene2D)
    return scene2D
}

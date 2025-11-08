//
//  ContentView.swift
//  SimpleGame
//
//  Created by Sergey Kozlov on 07.11.2025.
//

import SwiftUI
import TankEngine2D

struct ContentView: View {
    @State var scene: TEScene2D?
    @State var sceneData: Data?
    var body: some View {
        ZStack(alignment: .top) {
            if let scene {
                TESceneRender2D(scene: scene)
                HStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Button("Save") {
                            sceneData = TESceneSaver2D().save(scene)!
                        }
                        .background(.yellow)
                        Button("Load") {
                            guard let data = sceneData else { return }
                            guard let newScene = TESceneSaver2D().load(jsonData: data) else { return }
                            
                            TETankEngine2D.shared.reset(withScene: newScene)
                            TETankEngine2D.shared.start()
                            self.scene = newScene
                            
                        }
                        .background(.yellow)
                    }
                }
            }
        }
        .onAppear {
            scene = TETankEngine2D.shared.scene!
        }
        .onTapGesture {
            let playerNode = scene!.rootNode.children.first(where: { $0.tag == "player" })!
            let player = playerNode.getComponent(PlayerLogic.self)
            player?.tap()
        }
        
    }
}

#Preview {
  //  ContentView()
}

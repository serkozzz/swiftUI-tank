//
//  ContentView.swift
//  SimpleGame
//
//  Created by Sergey Kozlov on 07.11.2025.
//

import SwiftUI
import TankEngine2D

struct ContentView: View {
    
    @State var bbox: CGSize = CGSize(width: 100, height: 100)
    @State var scene = createSceneAndPrepareEngine()
    var body: some View {
        ZStack(alignment: .top) {
            
            TESceneRender2D(scene: scene)
            HStack {
                Spacer()
                HStack {
                    Spacer()
                    Button("Save") {
                        //vm.saveScene()
                    }
                    .background(.yellow)
                    Button("Load") {
                        //vm.loadScene()
                    }
                    .background(.yellow)
                }
            }
        }
        
        .onTapGesture {
           
        }
        
    }
}

#Preview {
    //  ContentView()
}


private func createSceneAndPrepareEngine() -> TEScene2D {
    
    let sceneBounds = CGRect(origin: CGPoint(x: -300, y: -100), size: CGSize(width: 600, height: 1000))
    let scene2D = TEScene2D(sceneBounds: sceneBounds)
    
    let rect = TESceneNode2D(position: SIMD2(0,200), viewType: RectView.self, tag: "player")
    scene2D.rootNode.addChild(TESceneNode2D(position: SIMD2(0,0), viewType: CircleView.self))
    scene2D.rootNode.addChild(TESceneNode2D(position: SIMD2(200,200), viewType: CircleView.self))
    scene2D.rootNode.addChild(rect)
    
    
    TETankEngine2D.shared.reset(withScene: scene2D)
    TETankEngine2D.shared.start(TEAutoRegistrator2D())
    return scene2D
}


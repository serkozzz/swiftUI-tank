//
//  ContentView.swift
//  SwiftUITank
//
//  Created by Sergey Kozlov on 26.08.2025.
//

import SwiftUI
import TankEngine2D
import simd

struct GameLevelView: View {

    private var levelManager: LevelManager
    private var levelContext: LevelContext { levelManager.levelContext }
    private var scene: TEScene2D { levelManager.levelContext.scene }
    
    init(levelManager: LevelManager) {
        self.levelManager = levelManager
    }
    
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Hello, world!")
            GameplayView(levelManager: levelManager)
            
            HStack {
                Button("up") {
                    scene.camera.move(simd_float2(0, 10))
                }
                Button("down") {
                    scene.camera.move(simd_float2(0, -10))
                }
            }

        }
        .padding()
    }
}

#Preview {
    let levelManager = LevelManager(scene: TEScene2D.default)
    GameLevelView(levelManager: levelManager)
        .environmentObject(levelManager)
}

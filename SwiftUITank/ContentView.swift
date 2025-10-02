//
//  ContentView.swift
//  SwiftUITank
//
//  Created by Sergey Kozlov on 26.08.2025.
//

import SwiftUI
import TankEngine2D
import simd

struct ContentView: View {

    @EnvironmentObject var gameManager: GameManager
    
    private var gameContext: GameContext { gameManager.gameContext }
    private var scene: TEScene2D { gameManager.gameContext.scene }
    
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Hello, world!")
            GameplayView(scene: scene, player: gameContext.player)
            
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
    ContentView()
        .environmentObject(GameManager())
}

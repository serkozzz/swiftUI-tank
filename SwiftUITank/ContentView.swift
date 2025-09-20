//
//  ContentView.swift
//  SwiftUITank
//
//  Created by Sergey Kozlov on 26.08.2025.
//

import SwiftUI
import simd

struct ContentView: View {

    @EnvironmentObject var gameModel: GameModel
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Hello, world!")
            Color.clear
                .playerController(scene: gameModel.scene)
            
            HStack {
                Button("up") {
                    gameModel.scene.camera.move(simd_float2(0, 10))
                }
                Button("down") {
                    gameModel.scene.camera.move(simd_float2(0, -10))
                }
            }

        }
        
        .padding()


    }
}

#Preview {
    ContentView()
        .environmentObject(GameModel())
}

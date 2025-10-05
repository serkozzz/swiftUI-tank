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

    @Binding var path: NavigationPath
    var levelManager: LevelManager
    
    private var levelContext: LevelContext { levelManager.levelContext }
    private var scene: TEScene2D { levelManager.levelContext.scene }
    
    var body: some View {
        VStack {
            Button("Back to menu") {
                path.removeLast()
            }
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
    @Previewable @State var path = NavigationPath()
    let levelManager = LevelManager(scene: TEScene2D.default)
    GameLevelView(path: $path, levelManager: levelManager)
        .environmentObject(levelManager)
}

//
//  GameMenuView.swift
//  SwiftUITank
//
//  Created by Sergey Kozlov on 05.10.2025.
//

import SwiftUI
import TankEngine2D

struct GameMenuView: View {
    
    @EnvironmentObject var gameManager: GameManager
    @Binding var path: NavigationPath
    
    var body: some View {
        VStack(spacing: 16) {
            Button("Level 1") {
                gameManager.levelManager = GameLevelManager(scene: TEScene2D.default)
                path.append(AppRoute.level)
                
            }
            Button("Level 2") {
                gameManager.levelManager = GameLevelManager(scene: TEScene2D.default2)
                path.append(AppRoute.level)
            }
            Button("Settings") {
                path.append(AppRoute.settings)
            }
        }
        .padding()
    }
}

#Preview {
    @Previewable @State var path = NavigationPath()
    GameMenuView(path: $path)
        .environmentObject(GameManager())
}

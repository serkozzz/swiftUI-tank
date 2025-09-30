//
//  SwiftUITankApp.swift
//  SwiftUITank
//
//  Created by Sergey Kozlov on 26.08.2025.
//

import SwiftUI
import TankEngine2D

@main
struct SwiftUITankApp: App {
    
    var gameModel = GameModel()
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(gameModel)
                .onAppear() {
                    TETankEngine2D.shared.start(scene: gameModel.scene)
                }
        }
        
    }
}

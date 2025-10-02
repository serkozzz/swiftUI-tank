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
    
    var gameManager = GameManager()
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(gameManager)
        }
        
    }
}

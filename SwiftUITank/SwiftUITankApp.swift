//
//  SwiftUITankApp.swift
//  SwiftUITank
//
//  Created by Sergey Kozlov on 26.08.2025.
//

import SwiftUI

@main
struct SwiftUITankApp: App {
    
    var gameModel = GameModel()
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(gameModel)
        }
    }
}

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
    @State var path = NavigationPath()
    
    var body: some Scene {
        WindowGroup {
            NavigationStack(path: $path) {
                GameMenuView(path: $path)
                    .environmentObject(gameManager)
                    .navigationDestination(for: AppRoute.self) { route in
                        switch route {
                        case .level:
                            if let levelManager = gameManager.levelManager {
                                GameLevelView(path: $path, levelManager: levelManager)
                            } else {
                                Text("No level selected")
                            }
                        case .settings:
                            Text("Settings")
                        case .mainMenu:
                            // Не пушим меню — оно уже корень. Если сюда попадёте, можно вернуть пустой view.
                            EmptyView()
                        }
                    }
            }
        }
    }
}

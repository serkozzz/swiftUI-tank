//
//  GameManager.swift
//  SwiftUITank
//
//  Created by Sergey Kozlov on 05.10.2025.
//

import SwiftUI
import TankEngine2D

@MainActor
class GameManager : ObservableObject {
    @Published var levelManager: GameLevelManager?
    
    init() {
        TEComponentsRegister2D.shared.register(Radar.self)
        TEComponentsRegister2D.shared.register(PlayerTank.self)
        TEComponentsRegister2D.shared.register(Building.self)
        
        TEComponentsRegister2D.shared.register(Cannon.self)
        TEComponentsRegister2D.shared.register(Bullet.self)
        TEComponentsRegister2D.shared.register(Radar.self)
        TEComponentsRegister2D.shared.register(Radar.self)
        TEComponentsRegister2D.shared.register(Radar.self)
        TEComponentsRegister2D.shared.register(PlayerController.self)
        
    }
}

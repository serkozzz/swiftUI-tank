//
//  FieldModel.swift
//  SwiftUITank
//
//  Created by Sergey Kozlov on 18.09.2025.
//

import SwiftUI
import TankEngine2D

class GameContext: ObservableObject {
    let scene = TEScene2D.default
    let playerTank: PlayerTank
    
    init() {
        
        playerTank = PlayerTank()
        scene.addPlayerTank(tankModel: playerTank)
    }
}



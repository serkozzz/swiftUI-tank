//
//  FieldModel.swift
//  SwiftUITank
//
//  Created by Sergey Kozlov on 18.09.2025.
//

import SwiftUI
import TankEngine2D

@MainActor
class GameLevelContext: ObservableObject {
    let scene: TEScene2D
    let playerTank: PlayerTank
    let playerController: PlayerController
    
    init(scene: TEScene2D, playerTank: PlayerTank, playerController: PlayerController) {
        self.scene = scene
        self.playerTank = playerTank
        self.playerController = playerController
    }
}



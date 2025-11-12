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
    var scene: TEScene2D
    var playerTank: PlayerTank
    var playerController: PlayerController
    
    init(scene: TEScene2D, playerTank: PlayerTank, playerController: PlayerController) {
        self.scene = scene
        self.playerTank = playerTank
        self.playerController = playerController
    }
}



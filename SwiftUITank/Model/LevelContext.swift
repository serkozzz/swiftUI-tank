//
//  FieldModel.swift
//  SwiftUITank
//
//  Created by Sergey Kozlov on 18.09.2025.
//

import SwiftUI
import TankEngine2D

@MainActor
class LevelContext: ObservableObject {
    let scene: TEScene2D
    let playerTank: PlayerTank
    
    init(scene: TEScene2D, playerTank: PlayerTank) {
        self.scene = scene
        self.playerTank = playerTank
    }
}



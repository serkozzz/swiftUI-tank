//
//  FieldModel.swift
//  SwiftUITank
//
//  Created by Sergey Kozlov on 18.09.2025.
//

import SwiftUI
import TankEngine2D

class GameModel: ObservableObject {
    let scene = TEScene2D.default
    let player: PlayerTank
    
    init() {
        player = PlayerTank()
        let playerNode = TESceneNode2D(position: SIMD2(x: 100, y: 100), component: player)
        scene.nodes.append(playerNode)
    }
}



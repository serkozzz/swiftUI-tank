//
//  FieldModel.swift
//  SwiftUITank
//
//  Created by Sergey Kozlov on 18.09.2025.
//

import SwiftUI
import TankEngine2D

class GameModel: ObservableObject {
    let scene = Scene2D.default
    let player: PlayerTank
    
    init() {
        player = PlayerTank()
        let playerNode = SceneNode(position: SIMD2(x: 100, y: 100), component: player)
        scene.nodes.append(playerNode)
    }
}



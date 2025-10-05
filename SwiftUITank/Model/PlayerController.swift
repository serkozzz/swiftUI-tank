//
//  PlayerController.swift
//  SwiftUITank
//
//  Created by Sergey Kozlov on 02.10.2025.
//

import SwiftUI
import Combine
import simd

@MainActor
class PlayerController {
    private let playerMover: PlayerMover
    private let playerTank: PlayerTank
    private let gameManager: LevelManager
    
    init(gameManager: LevelManager, playerTank: PlayerTank) {
        self.playerTank = playerTank
        self.playerMover = PlayerMover(playerTank: playerTank)
        self.gameManager = gameManager
    }
}

extension PlayerController: JoystickDelegate {
    func doubleTapped() {
        gameManager.spawnBullet(playerTank.shoot())
    }
    
    func dragBegan() {
        self.playerMover.dragBegan()
    }
    
    func dragChanged(state: JoystickState) {
        self.playerMover.dragChanged(state: state)
    }
    
    func dragEnded() {
        self.playerMover.dragEnded()
    }
    
    
}

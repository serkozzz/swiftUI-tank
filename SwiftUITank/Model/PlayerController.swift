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
    private let gameLevelManager: GameLevelManager
    
    init(gameManager: GameLevelManager, playerTank: PlayerTank) {
        self.playerTank = playerTank
        self.playerMover = PlayerMover(playerTank: playerTank)
        self.gameLevelManager = gameManager
    }
}

extension PlayerController: JoystickDelegate {
    func doubleTapped() {
        gameLevelManager.spawnBullet(playerTank.shoot())
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

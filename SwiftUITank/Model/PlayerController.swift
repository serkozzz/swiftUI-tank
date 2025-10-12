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
    
    init(gameLevelManager: GameLevelManager) {
        self.playerTank = gameLevelManager.levelContext.playerTank
        self.playerMover = gameLevelManager.levelContext.playerMover
        self.gameLevelManager = gameLevelManager
    }
}

extension PlayerController: JoystickDelegate {
    func joystickDidReceiveDoubleTap() {
        gameLevelManager.spawnBullet(playerTank.shoot())
    }
    
    func joystickDidBegin() {
        self.playerMover.joystickDidBegin()
    }
    
    func joystickDidChange(to state: JoystickState) {
        self.playerMover.joystickDidChange(to: state)
    }
    
    func joystickDidEnd() {
        self.playerMover.joystickDidEnd()
    }
}

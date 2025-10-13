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
    func joystickDidReceiveDoubleTap(id: JoystickID) {
        switch id {
        case .left:
            // при желании можно игнорировать или назначить другое действие
            gameLevelManager.spawnBullet(playerTank.shoot())
        case .right:
            gameLevelManager.spawnBullet(playerTank.shoot())
        }
    }
    
    func joystickDidBegin(id: JoystickID) {
        switch id {
        case .left:
            self.playerMover.joystickDidBegin()
        case .right:
            // зарезервировано под поведение правого стика (например, прицеливание)
            break
        }
    }
    
    func joystickDidChange(id: JoystickID, to state: JoystickState) {
        switch id {
        case .left:
            self.playerMover.joystickDidChange(to: state)
        case .right:
            // сюда можно добавить управление башней/прицеливание, если перенесёте его с DragGesture
            break
        }
    }
    
    func joystickDidEnd(id: JoystickID) {
        switch id {
        case .left:
            self.playerMover.joystickDidEnd()
        case .right:
            break
        }
    }
}

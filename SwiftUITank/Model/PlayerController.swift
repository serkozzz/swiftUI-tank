//
//  PlayerController.swift
//  SwiftUITank
//
//  Created by Sergey Kozlov on 02.10.2025.
//

import SwiftUI
import Combine
import simd
import TankEngine2D

@MainActor
protocol PlayerControllerDelegate: AnyObject {
    func playerController(_ playerController: PlayerController, initiatedShootingWith bullet: Bullet)
}

@MainActor
class PlayerController: TEComponent2D {
    private let playerMover: PlayerMover
    private let tankTurretMover: TankTurretMover
    private let playerTank: PlayerTank
    weak var delegate: PlayerControllerDelegate?
    
    init(_ playerTank: PlayerTank) {
        self.playerTank = playerTank
        self.playerMover = PlayerMover(playerTank, tankEngine2D: TETankEngine2D.shared)
        self.tankTurretMover = TankTurretMover(playerTank, tankEngine2D: TETankEngine2D.shared)
    }
    
    override func update(timeFromLastUpdate: TimeInterval) {
        playerMover.update(timeFromLastUpdate: timeFromLastUpdate)
        tankTurretMover.update(timeFromLastUpdate: timeFromLastUpdate)
    }
}

extension PlayerController: JoystickDelegate {
    func joystickDidReceiveDoubleTap(id: JoystickID) {
        switch id {
        case .left:
            delegate?.playerController(self, initiatedShootingWith: (playerTank.shoot()))
        case .right:
            delegate?.playerController(self, initiatedShootingWith: (playerTank.shoot()))
        }
    }
    
    
    func joystickDidBegin(id: JoystickID) {
        switch id {
        case .left:
            self.tankTurretMover.joystickDidBegin()
        case .right:
            self.playerMover.joystickDidBegin()
            break
        }
    }
    
    func joystickDidChange(id: JoystickID, to state: JoystickState) {
        switch id {
        case .left:
            self.tankTurretMover.joystickDidChange(to: state)
        case .right:
            self.playerMover.joystickDidChange(to: state)
            break
        }
    }
    
    func joystickDidEnd(id: JoystickID) {
        switch id {
        case .left:
            self.tankTurretMover.joystickDidEnd()
        case .right:
            self.playerMover.joystickDidEnd()
            break
        }
    }
}

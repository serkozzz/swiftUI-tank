//
//  PlayerMover.swift
//  SwiftUITank
//
//  Created by Sergey Kozlov on 18.09.2025.
//

import SwiftUI
import Combine
import simd
import TankEngine2D

@MainActor
class PlayerMover: TEComponent2D  {
    
    let playerTank: PlayerTank
    private var joystickState: JoystickState?
    private var isMoving = false

    init(_ playerTank: PlayerTank) {
        self.playerTank = playerTank
    }
    
    override func update(timeFromLastUpdate: TimeInterval) {
        if isMoving, let joystickState {
            if let intencity = joystickState.movementIntencity,
               let direction = joystickState.movementDirection
            {
                let distance = intencity * playerTank.maxSpeed * Float(timeFromLastUpdate)
                let movementVector = simd_normalize(direction) * distance
                playerTank.transform!.move(movementVector)
            }
        }
    }
}

//Joystik
extension PlayerMover {
    
    func dragBegan() {
        isMoving = true
    }
    
    func dragChanged(state: JoystickState) {
        self.joystickState = state
    }
    
    func dragEnded() {
        self.joystickState = nil
        isMoving = false
    }
}

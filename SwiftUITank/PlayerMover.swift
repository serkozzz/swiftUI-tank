//
//  PlayerMover.swift
//  SwiftUITank
//
//  Created by Sergey Kozlov on 18.09.2025.
//

import SwiftUI
import Combine
import simd

class PlayerMover {
    
    let playerTank: PlayerTank
    private var cancelables: Set<AnyCancellable> = []
    private var lastTickTime: Date?
    private var joystickState: JoystickState?
    private var isMoving = false
    
    init(playerTank: PlayerTank) {
        self.playerTank = playerTank
        
        Timer.publish(every: 0.05, on: .main, in: .common)
            .autoconnect()
            .sink { _ in
                print("Timer fired!")
                withAnimation(.linear(duration: 0.1)) { [self] in
                    self.timerTick()
                }
            }.store(in: &cancelables)
    }
    
    func timerTick() {
        guard var lastTickTime else {
            lastTickTime = Date.now
            return
        }
        let t = Date.now.timeIntervalSince(lastTickTime)
        lastTickTime = Date.now
        if isMoving, let joystickState {
            if let intencity = joystickState.movementIntencity,
               let direction = joystickState.movementDirection
            {
                let distance = intencity * playerTank.maxSpeed * Float(t)
                var movementVector = simd_normalize(direction) * distance
                movementVector.y = -movementVector.y
                playerTank.position =  playerTank.position  + movementVector
            }
        }
    }
}

extension PlayerMover: JoystickDelegate {
    
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

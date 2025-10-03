//
//  PlayerMover.swift
//  SwiftUITank
//
//  Created by Sergey Kozlov on 18.09.2025.
//

import SwiftUI
import Combine
import simd

@MainActor
class PlayerMover {
    
    let playerTank: PlayerTank
    private var cancelables: Set<AnyCancellable> = []
    private var lastTickTime: Date?
    private var joystickState: JoystickState?
    private var isMoving = false
    
    private let timerInterval = 0.05
    
    init(playerTank: PlayerTank) {
        self.playerTank = playerTank
        
        Timer.publish(every: timerInterval, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                // Hop to the main actor explicitly to call main-actor isolated APIs.
                Task { @MainActor in
                    self?.timerTick()
                }
            }
            .store(in: &cancelables)
    }
    

    func timerTick() {
        guard let lastTickTime else {
            lastTickTime = Date.now
            return
        }
        let t = Date.now.timeIntervalSince(lastTickTime)
        self.lastTickTime = Date.now
        if isMoving, let joystickState {
            if let intencity = joystickState.movementIntencity,
               let direction = joystickState.movementDirection
            {
                let distance = intencity * playerTank.maxSpeed * Float(t)
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

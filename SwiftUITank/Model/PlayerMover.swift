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
    private var tankEngine2D : TETankEngine2D

    init(_ playerTank: PlayerTank, tankEngine2D: TETankEngine2D) {
        self.playerTank = playerTank
        self.tankEngine2D = tankEngine2D
    }
    
    override func update(timeFromLastUpdate: TimeInterval) {
        if isMoving, let joystickState {
            if let intencity = joystickState.movementIntencity,
               let direction = joystickState.movementDirection
            {
                //playerTank.transform?.rotate(Angle(degrees: 3))
                
                let distance = intencity * playerTank.maxSpeed * Float(timeFromLastUpdate)
                let movementVector = simd_normalize(direction) * distance
                moveIfPossible(movementVector: simd_float2(x: 0, y: movementVector.y))
                moveIfPossible(movementVector: simd_float2(x: movementVector.x, y: 0))
                
            }
        }
    }
    
    func moveIfPossible(movementVector: simd_float2){
        
        
        let newPosition = playerTank.transform!.position + movementVector
        let predictiveMoveResult = tankEngine2D.predictiveMove(sceneNode: playerTank.owner!, newLocalTransform: TETransform2D(position: newPosition))
        
        guard predictiveMoveResult.isInsideSceneBounds else { return }
        guard predictiveMoveResult.colliders.isEmpty else { return }
       
        print(predictiveMoveResult.colliders)
        playerTank.transform!.move(movementVector)

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

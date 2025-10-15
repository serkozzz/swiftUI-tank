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
class PlayerMover  {
    
    let playerTank: PlayerTank
    private var joystickState: JoystickState?
    private var isMoving = false
    private var tankEngine2D : TETankEngine2D


    init(_ playerTank: PlayerTank, tankEngine2D: TETankEngine2D) {
        self.playerTank = playerTank
        self.tankEngine2D = tankEngine2D
    }
    
    func update(timeFromLastUpdate: TimeInterval) {
        if isMoving, let joystickState {
            
                let magnitude = joystickState.magnitude
                let toFinger = joystickState.normalizedToFingerVector
                
                let distance = toFinger.y * magnitude * playerTank.maxSpeed * Float(timeFromLastUpdate)
                let angle = Double(toFinger.x * magnitude * playerTank.maxTankAngularSpeed) * timeFromLastUpdate
                
                let movementVector = playerTank.tankDirectionLocal() * distance
            
                moveIfPossible(movementVector: simd_float2(x: 0, y: movementVector.y))
                moveIfPossible(movementVector: simd_float2(x: movementVector.x, y: 0))
            
            rotateIfPossible(clockwiseAngle: Angle.radians(angle))
                
        }
    }
    
    func moveIfPossible(movementVector: simd_float2){
        
        let predictiveMoveResult = tankEngine2D.predictiveMove(sceneNode: playerTank.owner!, worldDelta: movementVector)
        
        guard predictiveMoveResult.isInsideSceneBounds else { return }
        guard predictiveMoveResult.colliders.isEmpty else { return }
       
        print(predictiveMoveResult.colliders)
        playerTank.transform!.move(movementVector)

    }
    
    func rotateIfPossible(clockwiseAngle angle: Angle) {
        let predictiveRotResult = tankEngine2D.predictiveRotate(sceneNode: playerTank.owner!, localDeltaRotation: angle)
        
        guard predictiveRotResult.isInsideSceneBounds else { return }
        guard predictiveRotResult.colliders.isEmpty else { return }
       
        print(predictiveRotResult.colliders)
        playerTank.transform!.rotate(angle)
    }
}

//Joystik
extension PlayerMover {
    
    func joystickDidBegin() {
        isMoving = true
    }
    
    func joystickDidChange(to state: JoystickState) {
        self.joystickState = state
    }
    
    func joystickDidEnd() {
        self.joystickState = nil
        isMoving = false
    }
}

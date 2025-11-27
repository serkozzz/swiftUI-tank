//
//  TurretMover.swift
//  SwiftUITank
//
//  Created by Sergey Kozlov on 14.10.2025.
//

import TankEngine2D
import SwiftUI
import simd

@MainActor
class TankTurretMover {
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
                let x = joystickState.normalizedToFingerVector.x * magnitude
                let angle = timeFromLastUpdate * Double(playerTank.maxTurretAngularSpeed * x)
                let rotationTransform = TETransform2D(clockwiseRotation: Angle.radians(angle))
                let newBarrelDirection = rotationTransform.matrix * SIMD3<Float> (playerTank.barrelDirection, 0)
                playerTank.barrelDirection = SIMD2<Float>(newBarrelDirection)
                
               // moveIfPossible(movementVector: simd_float2(x: 0, y: movementVector.y))
                //moveIfPossible(movementVector: simd_float2(x: movementVector.x, y: 0))
                
        }
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
extension TankTurretMover {
    
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

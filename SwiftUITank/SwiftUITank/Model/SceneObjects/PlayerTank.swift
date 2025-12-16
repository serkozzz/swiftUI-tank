//
//  PlayerTankModel.swift
//  SwiftUITank
//
//  Created by Sergey Kozlov on 18.09.2025.
//

import SwiftUI
import TankEngine2D
import simd

@TESerializable
class PlayerTank: DamagableObject {
    
    @TESerializable @Published var barrelDirection: SIMD2<Float> = SIMD2<Float>(0, 1)
    @TESerializable var tankSize: CGSize = CGSize(width: 40, height: 60)
    let maxSpeed: Float = 100 // m/s
    let maxTankAngularSpeed = Float.pi / 3
    let maxTurretAngularSpeed = Float.pi
    
    func tankDirectionLocal() -> SIMD2<Float> {
        guard let transform else { return .zero }
        let tankRotationTransform = TETransform2D(transform)
        tankRotationTransform.setPosition(.zero)
        let direction = tankRotationTransform.matrix * SIMD3<Float>(0, 1, 1)
        return SIMD2<Float>(direction)
    }

    
    func shoot() -> Bullet {
        let nodeRotation = TETransform2D(worldTransform!)
        nodeRotation.setPosition(.zero)
        let bulletDirection = nodeRotation.matrix * SIMD3<Float>(barrelDirection, 0)
        return Bullet(self,
                      startPosition: worldTransform!.position,
                      directionVector: SIMD2<Float>(bulletDirection))
    }
}

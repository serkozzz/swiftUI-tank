//
//  Canon.swift
//  SwiftUITank
//
//  Created by Sergey Kozlov on 25.09.2025.
//

import SwiftUI
import Combine
import TankEngine2D
import TankEngine2DMacroInterfaces

@TESerializableType
class Cannon : DamagableObject {
    @TESerializable @Published var barrelAngleRadians: Double = 0
    @TESerializable var boundingBox: CGSize = CGSize(width: 50, height: 50)
    
    required init() {
        super.init()
    }
    
    override func update(timeFromLastUpdate: TimeInterval) {
        barrelAngleRadians += timeFromLastUpdate * 1
        barrelAngleRadians.formTruncatingRemainder(dividingBy: 2 * .pi)
    }
}


    

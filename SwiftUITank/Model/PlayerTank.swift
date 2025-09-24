//
//  PlayerTankModel.swift
//  SwiftUITank
//
//  Created by Sergey Kozlov on 18.09.2025.
//

import SwiftUI
import TankEngine2D
import simd

class PlayerTank: Component {
    @Published var barrelDirection = SIMD2<Float>(0, 1)
    var tankSize = CGSize(width: 40, height: 60)
    let maxSpeed: Float = 100 // m/s
}

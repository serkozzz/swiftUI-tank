//
//  PlayerTankModel.swift
//  SwiftUITank
//
//  Created by Sergey Kozlov on 18.09.2025.
//

import SwiftUI
import simd

class PlayerTank : ObservableObject {
    @Published var position = SIMD2<Float>(0, 0)
    @Published var barrelDirection = SIMD2<Float>(0, -1)
    var tankSize = CGSize(width: 40, height: 60)
    let maxSpeed: Float = 1 // m/s
}

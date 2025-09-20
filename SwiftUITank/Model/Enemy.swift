//
//  Enemy.swift
//  SwiftUITank
//
//  Created by Sergey Kozlov on 20.09.2025.
//
import SwiftUI

class Enemy : ObservableObject {
    @Published var position = SIMD2<Float>(0, 0)
    @Published var barrelDirection = SIMD2<Float>(0, -1)
    var tankSize = CGSize(width: 40, height: 60)
    let maxSpeed: Float = 1 // m/s
}

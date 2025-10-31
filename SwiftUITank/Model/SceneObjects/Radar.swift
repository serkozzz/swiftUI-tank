//
//  Radar.swift
//  SwiftUITank
//
//  Created by Sergey Kozlov on 12.10.2025.
//

import SwiftUI
import simd
import TankEngine2D

class Radar: DamagableObject {
    
    @Published var angle: Angle = .zero
    @Published var localPosition = SIMD2<Float>(50, 70)
    var color: Color!
    
    init(color: Color) {
        self.color = color
        super.init()
    }
    
    required init() {
        super.init()
    }
    
    override func start() {
        transform!.setPosition(localPosition)
    }
    
    override func update(timeFromLastUpdate: TimeInterval) {
        angle += Angle.degrees(1) * timeFromLastUpdate * 100
        transform!.setRotation(clockwiseAngle: angle)
    }
    
}

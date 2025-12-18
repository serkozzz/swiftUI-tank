//
//  Radar.swift
//  SwiftUITank
//
//  Created by Sergey Kozlov on 12.10.2025.
//

import SwiftUI
import simd
import TankEngine2D

@TESerializable
class Radar: DamagableObject {
    
    @TESerializable @Published var angle: Angle = .zero
    @TESerializable var size: CGSize = CGSize(width: 50, height: 50)
    
    var color: Color!
    
    init(color: Color) {
        self.color = color
        super.init()
    }
    
    required init() {
        super.init()
    }
    
    
    override func update(timeFromLastUpdate: TimeInterval) {
        angle += Angle.degrees(1) * timeFromLastUpdate * 100
        transform!.setRotation(clockwiseAngle: angle)
    }
    
}


extension Radar: TEVisualComponent2D {
    func createView() -> AnyView {
        AnyView(RadarView(viewModel: self))
    }
    
    var boundingBox: CGSize {
        self.size
    }
}

//
//  Canon.swift
//  SwiftUITank
//
//  Created by Sergey Kozlov on 25.09.2025.
//

import SwiftUI
import Combine
import TankEngine2D

@TESerializable
class Cannon : DamagableObject {
    @TESerializable @Published var barrelAngleRadians: Double = 0
    @TESerializable var size: CGSize = CGSize(width: 50, height: 50)
    @Published var building: Building = Building()
    
    required init() {
        super.init()
    }
    
    override func update(timeFromLastUpdate: TimeInterval) {
        barrelAngleRadians += timeFromLastUpdate * 1
        barrelAngleRadians.formTruncatingRemainder(dividingBy: 2 * .pi)
    }
}

    
extension Cannon: TEVisualComponent2D {
    func createView() -> AnyView {
        AnyView(CannonView(viewModel: self))
    }
    
    var boundingBox: CGSize {
        self.size
    }
}

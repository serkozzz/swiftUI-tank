//
//  Canon.swift
//  SwiftUITank
//
//  Created by Sergey Kozlov on 25.09.2025.
//

import SwiftUI
import Combine

class Cannon : DamagableObject {
    @Published var barrelAngleRadians: Double = 0
    
    init() {
        super.init()
    }
    
    override func update(timeFromLastUpdate: TimeInterval) {
        barrelAngleRadians += timeFromLastUpdate * 1
        barrelAngleRadians.formTruncatingRemainder(dividingBy: 2 * .pi)
    }
}


    

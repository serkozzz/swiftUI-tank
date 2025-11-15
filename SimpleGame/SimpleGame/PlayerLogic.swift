//
//  PlayerLogic].swift
//  SimpleGame
//
//  Created by Sergey Kozlov on 07.11.2025.
//

import Foundation
import TankEngine2D

@TESerializableType
class PlayerLogic: TEComponent2D {
    @TESerializable var boundingBox = CGSize(width: 100, height: 100)
    @TESerializable @Published var test = 100
    var isDead = false
    
    func tap() {
        printSerializableProperties() // генерится TESerializableTypeMacro
        owner?.transform.move(SIMD2(10,0))
        boundingBox.width += 50
    }
}


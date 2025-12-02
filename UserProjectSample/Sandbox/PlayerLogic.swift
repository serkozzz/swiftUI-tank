//
//  PlayerLogic].swift
//  SimpleGame
//
//  Created by Sergey Kozlov on 07.11.2025.
//

import Foundation
import TankEngine2D
import TankEngine2DMacroInterfaces 
import Combine
import SwiftUI

@TESerializableType
class PlayerLogic: TEComponent2D {
    @TESerializable @Published var boundingBox: CGSize = CGSize(width: 100, height: 100)
    @TESerializable var test: Int = 100
    var isDead = false
    
    func tap() {
        printSerializableProperties() // генерится TESerializableTypeMacro
        owner?.transform.move(SIMD2(10,0))
        boundingBox.width += 50
        
    }
}

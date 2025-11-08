//
//  PlayerLogic].swift
//  SimpleGame
//
//  Created by Sergey Kozlov on 07.11.2025.
//

import TankEngine2D

class PlayerLogic: TEComponent2D {
    
    func tap() {
        owner?.transform.move(SIMD2(10,0))
    }
}

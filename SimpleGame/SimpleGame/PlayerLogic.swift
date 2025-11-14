//
//  PlayerLogic].swift
//  SimpleGame
//
//  Created by Sergey Kozlov on 07.11.2025.
//

import Foundation
import TankEngine2D

class PlayerLogic: TEComponent2D {
    @TEPreviewable var boundingBox = CGSize(width: 100, height: 100)
    
    func tap() {
        // print_boundingBox()
        owner?.transform.move(SIMD2(10,0))
        boundingBox.width += 50
    }
}

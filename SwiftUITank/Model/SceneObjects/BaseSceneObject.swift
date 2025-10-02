//
//  BaseSceneObject.swift
//  SwiftUITank
//
//  Created by Sergey Kozlov on 25.09.2025.
//

import SwiftUI
import TankEngine2D

class BaseSceneObject: TEComponent2D {
    func removeFromScene() {
        let node = self.owner!
        node.parent!.removeChild( node)
    }
}

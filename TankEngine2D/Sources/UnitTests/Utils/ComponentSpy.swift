//
//  MockComponentWithRegistrator.swift
//  TankEngine2D
//
//  Created by Sergey Kozlov on 05.10.2025.
//

import Foundation
import TankEngine2D

class ComponentSpy: TEComponent2D {
    
    var startsNumber: Int = 0
    var updatesNumber: Int = 0
    var collisionsNumber: Int = 0
    var collisions: [TECollider2D] = []
    
    override func start() {
        startsNumber += 1
    }
    
    override func update(timeFromLastUpdate: TimeInterval) {
        updatesNumber += 1
    }

    
    override func collision(collider: TECollider2D) {
        collisionsNumber += 1
        collisions.append(collider)
    }
}

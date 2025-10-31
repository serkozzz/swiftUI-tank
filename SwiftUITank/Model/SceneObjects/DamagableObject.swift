//
//  DamagableObject.swift
//  SwiftUITank
//
//  Created by Sergey Kozlov on 01.10.2025.
//

import SwiftUI

class DamagableObject: BaseSceneObject {
    
    @Published var destroyed: Bool = false
    @Published var health: Int
    
    init(health: Int = 1) {
        self.health = health
    }

    required init() {
        health = 1
    }
    
    func takeDamage() {
        health -= 1
    }
    
    func destroy(complete: (() -> Void)? = nil) {
        destroyed = true
        
        complete?()
    }
}

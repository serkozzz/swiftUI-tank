//
//  Building.swift
//  SwiftUITank
//
//  Created by Sergey Kozlov on 25.09.2025.
//
import SwiftUI

class Building: BaseSceneObject {
    let floorsNumber: Int
    
    init(floorsNumber: Int = 5) {
        self.floorsNumber = floorsNumber
    }
}

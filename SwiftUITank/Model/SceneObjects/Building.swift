//
//  Building.swift
//  SwiftUITank
//
//  Created by Sergey Kozlov on 25.09.2025.
//
import SwiftUI

class Building: BaseSceneObject {
    var floorsNumber: Int = 5
    var boundingBox = CGSize(width: 50, height: 50)
    
    required init() {
        super.init()
    }
}

//
//  Building.swift
//  SwiftUITank
//
//  Created by Sergey Kozlov on 25.09.2025.
//
import SwiftUI

@TESerializableType
class Building: BaseSceneObject {
    @TESerializable var floorsNumber: Int = 5
    @TESerializable var boundingBox: CGSize = CGSize(width: 50, height: 50)
    
    required init() {
        super.init()
    }
}

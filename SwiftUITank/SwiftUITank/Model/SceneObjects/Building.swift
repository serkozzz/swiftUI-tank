//
//  Building.swift
//  SwiftUITank
//
//  Created by Sergey Kozlov on 25.09.2025.
//
import SwiftUI
import TankEngine2D

@TESerializable
class Building: BaseSceneObject {
    @TESerializable var floorsNumber: Int = 5
    @TESerializable var size: CGSize = CGSize(width: 50, height: 50)
    
    required init() {
        super.init()
    }
}



extension Building: TEVisualComponent2D {
    func createView() -> AnyView {
        AnyView(BuildingView(viewModel: self))
    }
    
    var boundingBox: CGSize {
        self.size
    }
}

//
//  Circle.swift
//  TankEditor
//
//  Created by Sergey Kozlov on 18.12.2025.
//

import SwiftUI
import TankEngine2D
import TankEngine2DMacroInterfaces

@TESerializableType
class CircleViewModel: TEComponent2D, @MainActor TEVisualComponent2D {
    
    @TESerializable @Published var size: CGSize = CGSize(width: 100, height: 100)
    
    public var boundingBox: CGSize {
        return size
    }
    
    public func createView() -> AnyView {
        AnyView(CircleView(viewModel: self))
    }
}

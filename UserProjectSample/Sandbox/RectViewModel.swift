//
//  TECollision2D.swift
//  TankEngine2D
//
//  Created by Sergey Kozlov on 02.10.2025.
//

import SwiftUI
import Combine
import TankEngine2D
import TankEngine2DMacroInterfaces


@TESerializableType
public class RectViewModel: TEComponent2D {

    @TESerializable @Published var size: CGSize = CGSize(width: 100, height: 100)
    
    @TESerializable var myStr: String = "string type"
    @Published var myNumber: Float = 30
    @Published var myBool: Bool = true
    @Published var myVector2: SIMD2<Float> = .one
    @Published var myVector3: SIMD3<Float> = .one
    
    var collider: TECollider2D = TECollider2D()
    @Published var camera: TECamera2D = TECamera2D()
}


extension RectViewModel: @MainActor TEVisualComponent2D {
    public var boundingBox: CGSize {
        return CGSize(width: 100, height: 100)
    }
    
    public func createView() -> AnyView {
        AnyView(RectView(viewModel: self))
    }
}


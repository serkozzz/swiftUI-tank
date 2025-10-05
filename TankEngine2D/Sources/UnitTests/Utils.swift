//
//  Utils.swift
//  TankEngine2D
//
//  Created by Sergey Kozlov on 03.10.2025.
//

import XCTest
import TankEngine2D
import SwiftUI
import Combine

@MainActor
func createScene() -> TEScene2D  {
    let go = TEGeometryObject2D(AnyView(EmptyView()), boundingBox: CGSize.zero)
    
    let node: TESceneNode2D = TESceneNode2D(position: SIMD2<Float>(0, 0), component: go)
    
    let camera = TECamera2D()
    let scene2D = TEScene2D(camera: camera)
    scene2D.rootNode.addChild(node)
    
    return scene2D
}

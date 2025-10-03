//
//  Scene.swift
//  SwiftUITank
//
//  Created by Sergey Kozlov on 20.09.2025.
//

import SwiftUI
import Combine

@MainActor
protocol TEScene2DDelegate: AnyObject {
    func teScene2D(_ scene: TEScene2D, didAddNode node: TESceneNode2D)
    func teScene2D(_ scene: TEScene2D, didRemoveNode node: TESceneNode2D)
    func teScene2D(_ scene: TEScene2D, didAttachComponent component: TEComponent2D, to node: TESceneNode2D)
    func teScene2D(_ scene: TEScene2D, didDetachComponent component: TEComponent2D, from node: TESceneNode2D)
}

@MainActor
public class TEScene2D: ObservableObject {
    
    @Published public var camera: TECamera2D
    @Published public var rootNode: TESceneNode2D
    
    weak var delegate: TEScene2DDelegate?
    
    private var nodeCancellables: Set<AnyCancellable> = []
    private var cancellables: Set<AnyCancellable> = []
    
    public init(camera: TECamera2D) {
        self.rootNode = TESceneNode2D(position: SIMD2.zero)
        self.camera = camera
        
        let cameraNode = TESceneNode2D(position: SIMD2<Float>(0, 0), component: camera)
        self.rootNode.addChild(cameraNode)
    }
}


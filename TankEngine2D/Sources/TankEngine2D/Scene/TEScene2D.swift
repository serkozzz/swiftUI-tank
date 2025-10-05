//
//  Scene.swift
//  SwiftUITank
//
//  Created by Sergey Kozlov on 20.09.2025.
//

import SwiftUI
import Combine

@MainActor
internal protocol TEScene2DDelegate: AnyObject {
    func teScene2D(_ scene: TEScene2D, didAddNode node: TESceneNode2D)
    func teScene2D(_ scene: TEScene2D, willRemoveNode node: TESceneNode2D)
    func teScene2D(_ scene: TEScene2D, didAttachComponent component: TEComponent2D, to node: TESceneNode2D)
    func teScene2D(_ scene: TEScene2D, willDetachComponent component: TEComponent2D, from node: TESceneNode2D)
}


// TEScene2D эмитит objectWillChange только при  добавлении/удалении нодов в дереве
@MainActor
public class TEScene2D: ObservableObject {
    
    @Published public var camera: TECamera2D
    @Published public var rootNode: TESceneNode2D
    
    weak var delegate: TEScene2DDelegate?
    
    private var nodeCancellables: Set<AnyCancellable> = []
    private var cancellables: Set<AnyCancellable> = []
    
    public init(camera: TECamera2D) {
        self.camera = camera
        
        self.rootNode = TESceneNode2D(position: SIMD2.zero)
        self.rootNode.scene = self
        
        let cameraNode = TESceneNode2D(position: SIMD2<Float>(0, 0), component: camera)
        self.rootNode.addChild(cameraNode)
        
    }
}


//MARK: scene delegate invokes
extension TEScene2D {
    
    func teScene2D(didAddNode node: TESceneNode2D) {
        delegate?.teScene2D(self, didAddNode: node)
        self.objectWillChange.send()
    }
    func teScene2D(willRemoveNode node: TESceneNode2D) {
        delegate?.teScene2D(self, willRemoveNode: node)
        self.objectWillChange.send()
    }
    func teScene2D(didAttachComponent component: TEComponent2D, to node: TESceneNode2D) {
        delegate?.teScene2D(self, didAttachComponent: component, to: node)
    }
    func teScene2D(willDetachComponent component: TEComponent2D, from node: TESceneNode2D) {
        delegate?.teScene2D(self, willDetachComponent: component, from: node)
    }
}

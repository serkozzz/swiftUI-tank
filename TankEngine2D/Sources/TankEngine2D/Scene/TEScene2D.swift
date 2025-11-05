//
//  Scene.swift
//  SwiftUITank
//
//  Created by Sergey Kozlov on 20.09.2025.
//

import Foundation
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
public class TEScene2D: @MainActor Codable, ObservableObject {
    
    @Published public var camera: TECamera2D
    @Published public var rootNode: TESceneNode2D
    public private(set) var sceneBounds: CGRect
    
    weak var delegate: TEScene2DDelegate?
    
    public init(sceneBounds: CGRect, camera: TECamera2D) {
        self.sceneBounds = sceneBounds
        self.camera = camera
        
        self.rootNode = TESceneNode2D(position: SIMD2.zero, debugName: "root")
        self.rootNode.scene = self
        
        let cameraNode = TESceneNode2D(position: SIMD2<Float>(0, 0), component: camera, debugName: "camera")
        self.rootNode.addChild(cameraNode)
        
    }
    
    //MARK: Codable
    enum CodingKeys: CodingKey {
        case rootNode, sceneBounds, cameraNodeId
    }
    
    public required init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        rootNode = try c.decode(TESceneNode2D.self, forKey: .rootNode)
        sceneBounds = try c.decode(CGRect.self, forKey: .sceneBounds)
        let cameraNodeId = try c.decode(UUID.self, forKey: .cameraNodeId)
        
        camera = TECamera2D() //temp empty camera to finish init and have ability to call methods of self
        self.restoreParents()
        self.restoreCamera(cameraNodeId: cameraNodeId)
    }

    public func encode(to encoder: Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        try c.encode(rootNode, forKey: .rootNode)
        try c.encode(sceneBounds, forKey: .sceneBounds)
        guard camera.owner != nil else { return }
        try c.encode(camera.owner!.id, forKey: .cameraNodeId)
    }
}


//MARK: Codable
extension TEScene2D {
    func restoreCamera(cameraNodeId: UUID) {
        guard let cameraNode = rootNode.getNodeBy(id: cameraNodeId) else {
            TELogger2D.print("Could not restoreCamera. CameraNode not found.")
            return
        }
        guard let camera = cameraNode.getComponent(TECamera2D.self) else {
            TELogger2D.print("Could not restoreCamera. CameraNode doesn't have camera component")
            return
        }
        self.camera = camera
    }
    
    func restoreParents() {
        restoreParentForChilds(of: rootNode)
    }
    
    func restoreParentForChilds(of node: TESceneNode2D) {
        for child in node.children {
            child.restoreParent(parent: node)
            restoreParentForChilds(of: child)
        }
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


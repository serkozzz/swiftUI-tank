//
//  SceneNodeDragManager.swift
//  TankEditor
//
//  Created by Sergey Kozlov on 11.12.2025.
//

import Foundation
import TankEngine2D
import UniformTypeIdentifiers



class SceneNodeDragManager {
    static let shared = SceneNodeDragManager()
    let utType = UTType.nodeRefDrag
    
    private(set) var draggingNode: TESceneNode2D?
    
    func startDrag(node: TESceneNode2D) {
        self.draggingNode = node
    }
    
    func finishDrag() {
        draggingNode = nil
    }
}

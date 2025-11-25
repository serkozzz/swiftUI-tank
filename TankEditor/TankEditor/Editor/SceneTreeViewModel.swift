//
//  ContentView.swift
//  Editor
//
//  Created by Sergey Kozlov on 17.11.2025.
//

import SwiftUI
import Combine
import TankEngine2D

class SceneTreeViewModel: ObservableObject {
    @Published private(set) var visibleNodes: [TESceneNode2D] = []
    
    private let scene: TEScene2D
    init(scene: TEScene2D) {
        self.scene = scene
        scene.addDelegate(self)
        self.updateVisibleNodes()
    }
    
    func updateVisibleNodes() {
        visibleNodes = [scene.rootNode] + scene.rootNode.children
    }
    
    func addRect() {
        scene.rootNode.addChild(TESceneNode2D(position: SIMD2.zero,
                                viewType: TERectangleView2D.self,
                                viewModelType: TERectangle2D.self,
                                name: scene.generateNodeName()))
    }
    
    func addEmptyNode() {
        scene.rootNode.addChild(TESceneNode2D(position: SIMD2.zero,
                                name: scene.generateNodeName()))
    }
    
    func handleDrop(asset: Asset, to node: TESceneNode2D) {
        let assetName = (asset.name as NSString).deletingPathExtension
        if let viewType = TEViewsRegister2D.shared.getTypeBy(assetName) {
            _ = node.attachView(viewType)
        } else if let componentType = TEComponentsRegister2D.shared.getTypeBy(assetName) {
            _ = node.attachComponent(componentType)
        }
        else {
            TELogger2D.error("Your asset is not view or component")
        }
    }
}


extension SceneTreeViewModel: TEScene2DDelegate {
    func teScene2D(_ scene: TankEngine2D.TEScene2D, didAddNode node: TankEngine2D.TESceneNode2D) {
        updateVisibleNodes()
    }
    
    func teScene2D(_ scene: TankEngine2D.TEScene2D, willRemoveNode node: TankEngine2D.TESceneNode2D) {
        updateVisibleNodes()
    }
}

#Preview {
    SceneTreeView(viewModel: SceneTreeViewModel(scene: ProjectContext.sampleContext.editorScene))
}

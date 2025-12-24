//
//  Scene2DViewModel.swift
//  TankEditor
//
//  Created by Sergey Kozlov on 30.11.2025.
//

import SwiftUI
import Combine
import TankEngine2D



class SceneRendererViewModel: ObservableObject {
    
    @Binding var selectedNode: TESceneNode2D?
    
    var projectContext: ProjectContext
    init(projectContext: ProjectContext, selectedNode: Binding<TESceneNode2D?>) {
        self.projectContext = projectContext
        self._selectedNode = selectedNode
    }
    
    func select(node: TESceneNode2D) {
        selectedNode = node
    }
}

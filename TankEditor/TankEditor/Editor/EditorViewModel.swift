//
//  EditorViewModel.swift
//  TankEditor
//
//  Created by Sergey Kozlov on 30.11.2025.
//

import SwiftUI
import Combine
import TankEngine2D

class EditorViewModel: ObservableObject {
    
    @Published var selectedNode: TESceneNode2D?
    
    var treeVM: SceneTreeViewModel!
    var sceneRenderViewModel: SceneRendererViewModel
    var propsInspectorVM: PropsInspectorViewModel
    
    
    var projectContext: ProjectContext
    
    init(projectContext: ProjectContext) {
        self.projectContext = projectContext
        
        self.propsInspectorVM = PropsInspectorViewModel(projectContext: projectContext)
        self.sceneRenderViewModel = SceneRendererViewModel(projectContext: projectContext, delegate: nil)
        self.sceneRenderViewModel.delegate = self
        self.treeVM = SceneTreeViewModel(scene: projectContext.editorScene, delegate: self)
    }
    
    
}

extension EditorViewModel: SceneTreeViewModelDelegate {
    func sceneTreeViewModel(_ viewModel: SceneTreeViewModel, didSelect node: TankEngine2D.TESceneNode2D) {
        propsInspectorVM.selectedNode = node
        treeVM.selectedNode = node
    }
}

extension EditorViewModel: SceneRendererViewModelDelegate {
    func sceneRendererViewModel(_ viewModel: SceneRendererViewModel, didSelect node: TankEngine2D.TESceneNode2D) {
        propsInspectorVM.selectedNode = node
        
        treeVM.selectedNode = node
    }
}

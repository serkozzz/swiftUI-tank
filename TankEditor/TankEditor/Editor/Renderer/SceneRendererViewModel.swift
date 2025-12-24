//
//  Scene2DViewModel.swift
//  TankEditor
//
//  Created by Sergey Kozlov on 30.11.2025.
//

import SwiftUI
import Combine
import TankEngine2D


protocol SceneRendererViewModelDelegate: AnyObject {
    func sceneRendererViewModel(_ viewModel: SceneRendererViewModel, didSelect node: TESceneNode2D)
}

class SceneRendererViewModel: ObservableObject {
    weak var delegate: SceneRendererViewModelDelegate?
    
    var projectContext: ProjectContext
    init(projectContext: ProjectContext, delegate: SceneRendererViewModelDelegate?) {
        self.projectContext = projectContext
        self.delegate = delegate
    }
    
    func select(node: TESceneNode2D) {
        delegate?.sceneRendererViewModel(self, didSelect: node)
    }
}

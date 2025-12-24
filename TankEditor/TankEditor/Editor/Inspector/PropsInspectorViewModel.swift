//
//  PropsInspectorViewModel.swift
//  TankEditor
//
//  Created by Sergey Kozlov on 30.11.2025.
//

import SwiftUI
import Combine
import TankEngine2D

class PropsInspectorViewModel: ObservableObject {
    var projectContext: ProjectContext
    private var cancellable: AnyCancellable?
    var selectedNode: TESceneNode2D? 
    
    init(projectContext: ProjectContext, selectedNode: TESceneNode2D?) {
        self.projectContext = projectContext
        self.selectedNode = selectedNode
        guard let selectedNode else {return}
        cancellable = selectedNode.objectWillChange.sink { [weak self] _ in
            self?.objectWillChange.send()
        }
    }
    
    func moveComponent(sourceIndex: Int, destIndex: Int) {
        selectedNode!.moveComponent(src: sourceIndex, dst: destIndex)
    }
    
    func indexOf(component: TEComponent2D) -> Int? {
        selectedNode?.components.firstIndex(of: component)
    }
}

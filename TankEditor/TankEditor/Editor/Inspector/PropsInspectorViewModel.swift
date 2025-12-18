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
    @Published var selectedNode: TESceneNode2D? {
        didSet {
            guard let selectedNode else {return}
            cancellable = selectedNode.objectWillChange.sink { [weak self] _ in
                self?.objectWillChange.send()
            }
        }
    }
    
    init(projectContext: ProjectContext) {
        self.projectContext = projectContext
    }
    
    func moveComponent(sourceIndex: Int, destIndex: Int) {
        selectedNode!.moveComponent(src: sourceIndex, dst: destIndex)
    }
}

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
    @Published var selectedNode: TESceneNode2D?
    
    init(projectContext: ProjectContext) {
        self.projectContext = projectContext
    }
}

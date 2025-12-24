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
    
    var projectContext: ProjectContext
    
    init(projectContext: ProjectContext) {
        self.projectContext = projectContext
    }
    
    
}

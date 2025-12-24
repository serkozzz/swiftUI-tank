//
//  Scene2DViewModel.swift
//  TankEditor
//
//  Created by Sergey Kozlov on 30.11.2025.
//

import SwiftUI
import Combine


class SceneRendererViewModel: ObservableObject {
    
    var projectContext: ProjectContext
    init(projectContext: ProjectContext) {
        self.projectContext = projectContext
    }
}

//
//  ProjectContext.swift
//  TankEditor
//
//  Created by Sergey Kozlov on 25.11.2025.
//
import SwiftUI
import TankEngine2D




class ProjectContext {
    var editorScene: TEScene2D
    var projectPath: String
    var projectName: String {
        (projectPath as NSString).lastPathComponent
    }

    init(scene: TEScene2D, projectPath: String) {
        self.editorScene = scene
        self.projectPath = projectPath
    }
}

extension ProjectContext {
    static var sampleContext: ProjectContext = {
        let sceneBounds = CGRect(origin: CGPoint(x: -500, y: -500), size: CGSize(width: 1000, height: 1000))
        let path = "/Users/sergeykozlov/Documents/TankEngineProjects/Sandbox"
        
        let scene = TEScene2D(sceneBounds: sceneBounds)
        var sceneNode = TESceneNode2D(position: .zero,
                                      viewType: TERectangleView2D.self,
                                      viewModelType: TERectangle2D.self,
                                      tag: "testNode")
        scene.rootNode.addChild(sceneNode)
        return ProjectContext(scene: scene, projectPath: path)
    }()
}


private struct ProjectContextKey: EnvironmentKey {
    static let defaultValue: ProjectContext? = nil
}


extension EnvironmentValues {
    var projectContext: ProjectContext? {
        get { self[ProjectContextKey.self] }
        set { self[ProjectContextKey.self] = newValue }
    }
}

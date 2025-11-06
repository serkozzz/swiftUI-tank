//
//  TESceneViewsAssembler.swift
//  TankEngine2D
//
//  Created by Sergey Kozlov on 06.11.2025.
//

class TESceneViewsCreator {
    private var viewBlueprints = [TEView2DBlueprint]()
    
    func addViewBlueprint(_ blueprints: [TEView2DBlueprint]) {
        viewBlueprints.append(contentsOf: blueprints)
    }
    
    func createAll(scene: TEScene2D)  {
        //TODO
    }
}

//
//  TESceneViewsAssembler.swift
//  TankEngine2D
//
//  Created by Sergey Kozlov on 06.11.2025.
//

import Foundation

@MainActor
class TESceneViewsCreator {
    private var viewBlueprints = [TEView2DBlueprint]()
    
    func addViewBlueprint(_ blueprints: [TEView2DBlueprint]) {
        viewBlueprints.append(contentsOf: blueprints)
    }
    
    func createAll(cache: [UUID: TEComponent2D], addUnresolvedRefs: (TEViewWithUnresolvedRefs2D) -> Void)  {
        for viewBlueprint in viewBlueprints {
            if let view = restoreView(from: viewBlueprint, cache: cache) {
                viewBlueprint.sceneNode.attachView(view)
                addUnresolvedRefs(TEViewWithUnresolvedRefs2D(sceneNode: viewBlueprint.sceneNode,
                                                             view: view,
                                                             refs: viewBlueprint.dto.refsToOtherComponents))
            }
            else {
                viewBlueprint.sceneNode.attachView(TEMissedView2D.self)
            }
                
            
        }
    }
    

    
    private func restoreView(from blueprint: TEView2DBlueprint, cache: [UUID: TEComponent2D]) -> (any TEView2D)? {
        
        let type = TEViewsRegister2D.shared.getTypeBy(blueprint.dto.structName)
        guard let type else {
            TELogger2D.print("Couldn't restore view. View with type \(blueprint.dto.structName) not registered")
            return nil
        }
        
        var vm: TEComponent2D? = nil
        if let viewModelRef = blueprint.dto.viewModelRef {
            vm = cache[viewModelRef]
            if (vm == nil) {
                TELogger2D.print("Couldn't restore viewModel for view with type \(blueprint.dto.structName). Component with that id is not in the scene.")
                //return nil
            }
        }
        var view = type.init(viewModel: vm)
        view.id = blueprint.dto.id
        return view
    }
}

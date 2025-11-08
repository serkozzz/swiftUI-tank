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
        
        let type = TEViewsRegister2D.shared.registredViews[blueprint.dto.structName]
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
        restorePreviewableProperties(for: view, from: blueprint.dto)
        return view
    }
    
    
    private func restorePreviewableProperties(for view: any TEView2D, from encodedView:TEViewDTO) {
        
        Mirror.propsForeach(view) { child in
            
                guard let previewable = child.value as? TEPreviewable2DProtocol else { return }
                guard let property = encodedView.properties.first(where: { $0.propertyName == child.label}) else { return }
                
                let innerType = previewable.self.valueType
                guard let decodedValue = try? JSONDecoder().decode(innerType, from: property.propertyValue)
                else {
                    TELogger2D.print("Could not restore innerValue for Previewable<> property: \(property.propertyName) of type: \(String(describing: previewable.valueType))")
                    return
                }
                
                // Устанавливаем значение внутрь обёртки
                if !previewable.setValue(decodedValue) {
                    TELogger2D.print("Type mismatch when assigning decoded value to Previewable<> property: \(property.propertyName)")
                }

        }
    }
}

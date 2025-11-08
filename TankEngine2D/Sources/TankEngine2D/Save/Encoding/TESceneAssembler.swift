//
//  TESceneAssembler.swift
//  TankEngine2D
//
//  Created by Sergey Kozlov on 06.11.2025.
//
import Foundation
@MainActor

class TESceneAssembler {
    private let linker = TESceneLinker()
    private let viewsCreator = TESceneViewsCreator()
    private var componentsCache = [UUID: TEComponent2D]()
    
    func cache(_ component: TEComponent2D) {
        componentsCache[component.id] = component
    }
    
    func addUnresolvedRefs(_ refs: [TEComponentWithUnresolvedRefs2D]) {
        linker.addRefs(refs)
    }
    
    func addUnresolvedRefs(_ refs: [TEViewWithUnresolvedRefs2D]) {
        linker.addRefs(refs)
    }
    
    func resolveLinks() {
        linker.resolveLinks(componentsCache: componentsCache)
    }
    
    func addViewBlueprints(_ blueprints: [TEView2DBlueprint])  {
        viewsCreator.addViewBlueprint(blueprints)
    }
    
    func createViewsFromBlueprints(scene: TEScene2D) {
        viewsCreator.createAll(cache: componentsCache, addUnresolvedRefs: {ref in
          addUnresolvedRefs([ref])
        })
    }
}

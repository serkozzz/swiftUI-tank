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
    private var componentsCache = [UUID: TEComponent2D]()
    
    func cache(_ component: TEComponent2D) {
        componentsCache[component.id] = component
    }
    
    func addUnresolvedRefs(_ refs: [TEComponentWithUnresolvedRefs2D]) {
        linker.addRefs(refs)
    }
    
    func resolveLinks() {
        linker.resolveLinks(componentsCache: componentsCache)
    }
}

extension CodingUserInfoKey {
    static let sceneAssembler = CodingUserInfoKey(rawValue: "sceneAssembler")!
}


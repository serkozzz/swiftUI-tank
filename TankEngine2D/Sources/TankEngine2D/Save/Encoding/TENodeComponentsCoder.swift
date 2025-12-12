//
//  TEComponentSerializer2D.swift
//  TankEngine2D
//
//  Created by Sergey Kozlov on 04.11.2025.
//

import Foundation


@MainActor
class TENodeComponentsCoder {
    
    
    func encodeComponents(_ components: [TEComponent2D]) -> [TEComponentDTO] {
        return components.map { encodeComponent($0)}
    }
    
    func restoreComponents(_ encodedComponents: [TEComponentDTO],
                           for sceneNode: TESceneNode2D,
                           sceneAssembler: TESceneAssembler) {
        let componentsWithRefs = encodedComponents.map { restoreComponent(from:$0, for: sceneNode) }
    
        sceneAssembler.addUnresolvedRefs(componentsWithRefs.compactMap{$0}.filter{ !$0.refs.isEmpty })
        let restoredComponents = componentsWithRefs.map{ $0 == nil ? TEMissedComponent2D() : $0!.component}
        restoredComponents.forEach { sceneAssembler.cache($0)}
    }
    
    private func encodeComponent(_ component: TEComponent2D) -> TEComponentDTO {
        
        let className = TEComponentsRegister2D.shared.getKeyFor(type(of: component))
        let dict = component.encodeSerializableProperties()
        let refs = encodeRefs(component)
        let id = component.id
        return TEComponentDTO(className: className, propertiesDictJson: dict, refsToOtherComponents: refs, componentID: id)
    }
    
    private func restoreComponent(from dto: TEComponentDTO, for sceneNode: TESceneNode2D) -> TEComponentWithUnresolvedRefs2D? {
        let type = TEComponentsRegister2D.shared.getTypeBy(dto.className)
        guard let type else {
            TELogger2D.error("\(String(describing: type)) isn't registered")
            return nil
        }
    
        let component = sceneNode.attachComponent(type)
        component.id = dto.componentID
        component.decodeSerializableProperties(dto.propertiesDictJson)
        return TEComponentWithUnresolvedRefs2D(component: component,
                                               refs: dto.refsToOtherComponents)
    }
    
    private func encodeRefs(_ component: TEComponent2D) -> [TEComponentRefDTO] {
        var result = [TEComponentRefDTO]()

        for (propName, component) in component.allTEComponentRefs() {
            
            if (propName == "_rectangle") {
                var a = 10
                a += 10
            }
            guard let component else { continue }
            guard let encodedRef = TECoderHelper.encodeRef(propertyName: propName, componentRef: component) else { continue }
            result.append( encodedRef )
        }
        return result
    }
}


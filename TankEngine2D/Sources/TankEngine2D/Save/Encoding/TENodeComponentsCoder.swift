//
//  TEComponentSerializer2D.swift
//  TankEngine2D
//
//  Created by Sergey Kozlov on 04.11.2025.
//

import Foundation
import SafeKVC

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
        
        guard let serializable = component as? TESerializableType else {
            TELogger2D.error("\(String(describing: type(of: component))) doesn't have @TESerializableType. All classes derived TEComponent2D should be marked @TESerializableType")
            fatalError()
        }
        let className = String(reflecting: type(of: component))
        let dict = serializable.encodeSerializableProperties()
        let refs = encodeRefs(component)
        let id = component.id
        return TEComponentDTO(className: className, propertiesDictJson: dict, refsToOtherComponents: refs, componentID: id)
    }
    
    private func restoreComponent(from dto: TEComponentDTO, for sceneNode: TESceneNode2D) -> TEComponentWithUnresolvedRefs2D? {
        let type = TEComponentsRegister2D.shared.registredComponents[dto.className]
        guard let type else {
            TELogger2D.error("\(String(describing: type)) isn't registered")
            return nil
        }
    
        let component = sceneNode.attachComponent(type)
        component.id = dto.componentID
        guard let serializable = component as? TESerializableType else {
            TELogger2D.error("Component could not be restored. \(String(describing: type))) doesn't have @TESerializableType. Probably it has @TESerializableType when scene was saved. But now it does'nt have.")
            return nil
        }
        serializable.decodeSerializableProperties(dto.propertiesDictJson)
        return TEComponentWithUnresolvedRefs2D(component: component,
                                               refs: dto.refsToOtherComponents)
    }
    
    private func encodeRefs(_ component: TEComponent2D) -> [TEPropertyDTO] {
        var result = [TEPropertyDTO]()

        Mirror.propsForeach(component) { child in
                
            guard let encodedRef = TECoderHelper.tryEncodeRef(mirrorProp: child) else { return }
                result.append( encodedRef )
        }
        
        return result
    }
}


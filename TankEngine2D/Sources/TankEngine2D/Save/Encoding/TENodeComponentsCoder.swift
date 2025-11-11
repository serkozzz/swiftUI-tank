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
    
    func restoreComponents(_ encodedComponents: [TEComponentDTO], sceneAssembler: TESceneAssembler) -> [TEComponent2D] {
        let componentsWithRefs = encodedComponents.map(restoreComponent(from:))
    
        sceneAssembler.addUnresolvedRefs(componentsWithRefs.compactMap{$0}.filter{ !$0.refs.isEmpty })
        let restoredComponents = componentsWithRefs.map{ $0 == nil ? TEMissedComponent2D() : $0!.component}
        restoredComponents.forEach { sceneAssembler.cache($0)}
        return restoredComponents
    }
    
    private func encodeComponent(_ component: TEComponent2D) -> TEComponentDTO {
        let className = String(reflecting: type(of: component))
        let properties = encodePreviewable(component)
        let refs = encodeRefs(component)
        let id = component.id
        return TEComponentDTO(className: className, properties: properties, refsToOtherComponents: refs, componentID: id)
    }
    
    private func restoreComponent(from encodedComponent: TEComponentDTO) -> TEComponentWithUnresolvedRefs2D? {
        let type = TEComponentsRegister2D.shared.registredComponents[encodedComponent.className]
        guard let type else { return nil }
    
        let component = type.init()
        component.id = encodedComponent.componentID
    
        restorePreviewableProperties(for: component, from: encodedComponent)
        return TEComponentWithUnresolvedRefs2D(component: component,
                                               refs: encodedComponent.refsToOtherComponents)
    }
    
    
    private func encodePreviewable(_ component: TEComponent2D) -> [TEPropertyDTO] {
        var result = [TEPropertyDTO]()
    
        Mirror.propsForeach(component) { child in
            guard let encodedProp = TECoderHelper.tryEncodePreviewable(mirrorProp: child) else { return }
            result.append(encodedProp)
        }
        
        return result
    }
    
    private func encodeRefs(_ component: TEComponent2D) -> [TEPropertyDTO] {
        var result = [TEPropertyDTO]()

        Mirror.propsForeach(component) { child in
                
            guard let encodedRef = TECoderHelper.tryEncodeRef(mirrorProp: child) else { return }
                result.append( encodedRef )
        }
        
        return result
    }
    
    private func restorePreviewableProperties(for component: TEComponent2D, from encodedComponent:TEComponentDTO) {
        
        Mirror.propsForeach(component) { child in
            
            guard let previewable = TECoderHelper.restorePreviewableProperty(mirrorProp: child, allPropertieDTOs: encodedComponent.properties) else { return }
            SafeKVC.setValue(previewable, forKey: child.label!, of: component)
        }
        
    }

}


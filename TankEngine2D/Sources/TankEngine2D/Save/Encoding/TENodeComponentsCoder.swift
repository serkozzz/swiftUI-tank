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
        
        if (encodedComponent.className.contains("PlayerController")) {
            var a = 10
        }
        if !encodedComponent.refsToOtherComponents.isEmpty {
            var a = 10
        }
        restorePreviewableProperties(for: component, from: encodedComponent)
        return TEComponentWithUnresolvedRefs2D(component: component,
                                               refs: encodedComponent.refsToOtherComponents)
    }
    
    
    private func encodePreviewable(_ component: TEComponent2D) -> [TEPropertyDTO] {
        var result = [TEPropertyDTO]()
    
        Mirror.propsForeach(component) { child in
                guard let previewable = child.value as? TEPreviewable2DProtocol else { return }
                guard let propertyName = child.label else { return }
                
                
                let valueData = try! JSONEncoder().encode(previewable.value)
                result.append( TEPropertyDTO(propertyName: propertyName,
                                                            propertyValue: valueData,
                                                            propertyType: String(reflecting: previewable.valueType) ))
        }
        
        return result
    }
    
    private func encodeRefs(_ component: TEComponent2D) -> [TEPropertyDTO] {
        var result = [TEPropertyDTO]()

        Mirror.propsForeach(component) { child in
                
                guard let componentRef = child.value as? TEComponent2D else { return }
                guard let propertyName = child.label else { return }
                
                
                let valueData = try! JSONEncoder().encode(componentRef.id)
                result.append( TEPropertyDTO(propertyName: propertyName,
                                                            propertyValue: valueData,
                                                            propertyType: String(reflecting: UUID.self) ))
        }
        
        return result
    }
    
    private func restorePreviewableProperties(for component: TEComponent2D, from encodedComponent:TEComponentDTO) {
        
        Mirror.propsForeach(component) { child in
            
                guard var previewable = child.value as? TEPreviewable2DProtocol else { return }
                guard let property = encodedComponent.properties.first(where: { $0.propertyName == child.label}) else { return }
                
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


//
//  TEComponent2DJSONRepresentation.swift
//  TankEngine2D
//
//  Created by Sergey Kozlov on 03.11.2025.
//

import Foundation
import SafeKVC

@MainActor
struct TEEncodedComponent2D: @MainActor Codable {
    var className: String
    var properties: [TEEncodedComponent2DProperty]
    var refsToOtherComponents: [TEEncodedComponent2DProperty]
    var componentID: UUID
    
    init(_ component: TEComponent2D) throws {
        self.className = String(reflecting: type(of: component))
        properties = TEEncodedComponent2D.encodePreviewable(component)
        refsToOtherComponents = TEEncodedComponent2D.encodedRefs(component)
        componentID = component.id
    }
    
    func restoreComponent() -> TEComponent2D {
        let type = TEComponentsRegister2D.shared.registredComponents[className]
        guard let type else { return TEMissedComponent2D() }
    
        let component = type.init()
        component.id = self.componentID
        restorePreviewableProperties(for: component)
        return component
    }
}



extension TEEncodedComponent2D {
    
    
    static func encodePreviewable(_ component: TEComponent2D) -> [TEEncodedComponent2DProperty] {
        var result = [TEEncodedComponent2DProperty]()
    
        propsForeach(component) { child in
                guard let previewable = child.value as? TEPreviewable2DProtocol else { return }
                guard let propertyName = child.label else { return }
                
                
                let valueData = try! JSONEncoder().encode(previewable.value)
                result.append( TEEncodedComponent2DProperty(propertyName: propertyName,
                                                            propertyValue: valueData,
                                                            propertyType: String(reflecting: previewable.valueType) ))
        }
        
        return result
    }
    
    static func encodedRefs(_ component: TEComponent2D) -> [TEEncodedComponent2DProperty] {
        var result = [TEEncodedComponent2DProperty]()

        propsForeach(component) { child in
                
                guard let componentRef = child.value as? TEComponent2D else { return }
                guard let propertyName = child.label else { return }
                
                
                let valueData = try! JSONEncoder().encode(componentRef.id)
                result.append( TEEncodedComponent2DProperty(propertyName: propertyName,
                                                            propertyValue: valueData,
                                                            propertyType: String(reflecting: UUID.self) ))
        }
        
        return result
    }
    
    private func restorePreviewableProperties(for component: TEComponent2D) {
        
        propsForeach(component) { child in
            
                guard let previewable = child.value as? TEPreviewable2DProtocol else { return }
                guard let property = self.properties.first(where: { $0.propertyName == child.label}) else { return }
                
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

private func propsForeach(_ subject: Any, action: (Mirror.Child) -> ())  {
    var current: Mirror? = Mirror(reflecting: subject)
    while let mirror = current {
        for child in mirror.children {
            action(child)
        }
        current = mirror.superclassMirror
    }
}
